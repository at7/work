
#include <stdio.h>
#include <getopt.h>
#include <stdlib.h>
#include <string.h>

#define MAX_REGIONS 100
#define WINDOW_SIZE 100000
#define INITIAL_LIST_SIZE 256
#define SYSTEM_ERROR 2
#define MIN_GENOTYPES_LOCUS 40
#define THETA_CONVERGENCE_THRESHOLD 0.0001
#define MIN_R2 0.05


/* Macros for fetching particular haplotypes from the allele_counters */
#define AABB allele_counters[0x0000]
#define AABb allele_counters[0x0001]
#define AAbb allele_counters[0x0003]
#define AaBB allele_counters[0x0004]
#define AaBb allele_counters[0x0005]
#define Aabb allele_counters[0x0007]
#define aaBB allele_counters[0x000c]
#define aaBb allele_counters[0x000d]
#define aabb allele_counters[0x000f]

/* Macro which turns pairs of characters into a two bit integer */
#define genotype2int(g) (((g[0] & 0x20) >> 4) | ((g[1] & 0x20) >> 5))

typedef struct {
	int person_id;
	uint8_t genotype;
} Genotype;

typedef struct{
	int position;
	char *var_id;
	int number_genotypes;
	Genotype * genotypes;
} Locus_info;

typedef struct{
	double D;
	double r2;
	double theta;
	int N;
	double d_prime;
	int people;
} Stats;

typedef struct {
	int head;
	int tail;
	int sz;
	Locus_info *locus;
} Locus_list;

typedef struct{
	int number_haplotypes;
	uint8_t * haplotype;
} Haplotype;

void init_locus_list(Locus_list *l) {
  l->sz = INITIAL_LIST_SIZE;
  l->tail = -1;
  l->head = 0;
  l->locus = malloc(INITIAL_LIST_SIZE*sizeof(Locus_info));
  if (l->locus == NULL) {
    perror("Could not allocate memory");
    exit(SYSTEM_ERROR);
  }
}



int main(int argc, char *argv[]) {

// parse args
	int c;
	char *filestr = NULL;
	char *regionstr = NULL;
	char *samples_list = NULL;
	char *variants_file = NULL;
	char *variant = NULL;
	int numregions = MAX_REGIONS;
	int windowsize = WINDOW_SIZE;
	int var_position = 0;

	while(1) {
		static struct option long_options[] = {
			{"file",       required_argument, 0, 'f'},
			{"region",     required_argument, 0, 'r'},
			{"numregions", required_argument, 0, 's'},
			{"samples",    required_argument, 0, 'l'},
			{"window",     required_argument, 0, 'w'},
			{"variant",    required_argument, 0, 'v'},
			{"var_position", required_argument, 0, 'p'},
			{"include_variants", required_argument, 0, 'n'},
			{0, 0, 0, 0}
		};

/* getopt_long stores the option index here. */
		int option_index = 0;

		c = getopt_long (argc, argv, "f:l:r:s:w:v:n:p:", long_options, &option_index);

/* Detect the end of the options. */
		if (c == -1)
			break;

		switch (c) {

			case 'f':
			filestr = optarg;
			break;

			case 'r':
			regionstr = optarg;
			break;

			case 's':
			numregions = (int) atoi(optarg);
			break;

			case 'l':
			samples_list = optarg;
			break;

			case 'w':
			windowsize = (int) atoi(optarg);
			break;

			case 'v':
			variant = optarg;
			break;

			case 'p':
			var_position = (int) atoi(optarg);
			break;

			case 'n':
			variants_file = optarg;
			break;

			case '?':
    /* getopt_long already printed an error message. */
			break;

			default:
			abort ();
		}
	}


	if (numregions > MAX_REGIONS) {
		fprintf(stderr, "Number of maximum allowed regions exceeded: %d.\n", numregions);
		return EXIT_FAILURE;
	}

	char *files[numregions];
	int file_index = 0;
	char *token = strtok(filestr, ",");
	files[file_index++] = token;
// Keep printing tokens while one of the delimiters present in str[].
	while (token != NULL) {
		token = strtok(NULL, ",");
		files[file_index++] = token;
	}

	char *regions[numregions];
	int region_index = 0;
	token = strtok(regionstr, ",");
	regions[region_index++] = token;
// Keep printing tokens while one of the delimiters present in str[].
	while (token != NULL) {
		token = strtok(NULL, ",");
		regions[region_index++] = token;
	}

	if (file_index > MAX_REGIONS) {
		fprintf(stderr, "Number of maximum allowed regions exceeded: %d.\n", file_index);
		return EXIT_FAILURE;
	}

	if(file_index == 0) {
		fprintf(stderr, "No file(s) specified with -f\n");
		usage(argv[0]);
		return EXIT_FAILURE;
	}

	if(region_index == 0) {
		fprintf(stderr, "No region(s) specified with -r\n");
		usage(argv[0]);
		return EXIT_FAILURE;
	}

	if(file_index != region_index) {
		fprintf(stderr, "Number of files does not match number of regions\n");
		usage(argv[0]);
		return EXIT_FAILURE;
	}
	if(numregions > 1) {
		windowsize = 1000000000;
	}


// open output
	FILE *fh;
	fh = stdout; // fopen("output.txt","w");


	// init vars
	Locus_list locus_list;
	init_locus_list(&locus_list);
	int f;
	int position = 0;
	int variant_index = -1;
	for(f=0; f<numregions; f++) {

// open htsFile
		htsFile *htsfile = hts_open(files[f], "rz");

		if(!htsfile) {
			fprintf(stderr, "Unable to open file %s\n", files[f]);
			return EXIT_FAILURE;
		}

// read header
		bcf_hdr_t *hdr = bcf_hdr_read(htsfile);

		if(!hdr) {
			fprintf(stderr, "Unable to read header from file %s\n", files[f]);
			return EXIT_FAILURE;
		}

// use sample list if provided
// this speeds up VCF parsing
		if(samples_list) {

  // can be a file
			int is_file = 1;

  // or a comma-separated list
			if(strstr(samples_list, ",") != NULL) {
				is_file = 0;
			}
			else if(access( samples_list, F_OK ) < 0) {
				fprintf(stderr, "Failed to read samples list %s\n", samples_list);
				return EXIT_FAILURE;
			}

			if(bcf_hdr_set_samples(hdr, samples_list, is_file) < 0) {
				fprintf(stderr, "Failed to read or set samples\n");
				return EXIT_FAILURE;
			}
		}

// get file format and act accordingly
		enum htsExactFormat format = hts_get_format(htsfile)->format;

		if(format == vcf) {

  // open index
			tbx_t *idx = tbx_index_load(files[f]);

			if(!idx) {
				fprintf(stderr, "Could not load .tbi/.csi index for file %s\n", files[f]);
				return EXIT_FAILURE;
			}

  // query
			hts_itr_t *itr = tbx_itr_querys(idx, regions[f]);

  // dive out without iter
			if(!itr) return 0;

  // set up vars
			kstring_t str = {0,0,0};
			bcf1_t *line = bcf_init();

  // iterate over file
			while(tbx_itr_next(htsfile, idx, itr, &str) > 0) {

    // parse into vcf struct as line
				if(vcf_parse(&str, hdr, line) == 0) {

      // check include_variants
					if(have_include_variants && check_include_variants(line, include_variants, variant) == 0) 
						continue;

					position = line->pos + (2 - bcf_is_snp(line));
					if (windowsize && variant_index > 0 && abs(position - locus_list.locus[variant_index].position) > windowsize)
						continue;

					if (get_genotypes(&locus_list, hdr, line, position)) {
						if (!variant && !var_position) {
							process_window(&locus_list, windowsize, fh, position);
						} else if (variant) {
							if (!strcmp(variant, locus_list.locus[locus_list.tail].var_id)) {
								variant_index = locus_list.tail;
							}
						} else if (var_position) {
							if (var_position == locus_list.locus[locus_list.tail].position) {
								variant_index = locus_list.tail;
							}
						}
					}
				}
			}

			free(str.s);
			tbx_destroy(idx);
			tbx_itr_destroy(itr);
		}

		else if(format == bcf) {

  // open index
			hts_idx_t *idx = bcf_index_load(files[f]);

			if(!idx) {
				fprintf(stderr, "Could not load .csi index for file %s\n", files[f]);
				return EXIT_FAILURE;
			}

  // query
			hts_itr_t *itr = bcf_itr_querys(idx, hdr, regions[f]);

  // dive out without iter
			if(!itr) return 0;

			bcf1_t *line = bcf_init();

			while(bcf_itr_next(htsfile, itr, line) >= 0) {
    // check include_variants
				if(have_include_variants && check_include_variants(line, include_variants, variant) == 0) 
					continue;

				position = line->pos + (2 - bcf_is_snp(line));
				if (windowsize && variant_index > 0 && abs(position - locus_list.locus[variant_index].position) > windowsize)
					continue;

				if (get_genotypes(&locus_list, hdr, line, position)) {
					if (!variant && !var_position) {
						process_window(&locus_list, windowsize, fh, position);
					} else if (variant) {
						if (!strcmp(variant, locus_list.locus[locus_list.tail].var_id)) {
							variant_index = locus_list.tail;
						}
					} else if (var_position) {
						if (var_position == locus_list.locus[locus_list.tail].position) {
							variant_index = locus_list.tail;
						}
					}
				}
			}

			hts_idx_destroy(idx);
			bcf_itr_destroy(itr);
		}

		else {
			fprintf(stderr, "Unsupported format for file %s\n", files[f]);
			return EXIT_FAILURE;
		}

		bcf_hdr_destroy(hdr);

		if ( hts_close(htsfile) ) {
			fprintf(stderr, "hts_close returned non-zero status: %s\n", files[f]);
			return EXIT_FAILURE;
		}
	}

	if (!variant) {
// process any remaining buffer
		process_window(&locus_list, 0, fh, position);
} else if (variant_index >= 0) { // Variable initialised to -1, if set correctly, set to int >= 0
// Compute LD around variant of interest
	calculate_ld(&locus_list, fh, windowsize, variant_index);
}
return 0;

}






