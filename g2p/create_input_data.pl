use strict;
use warnings;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;
use Bio::EnsEMBL::Registry;
use FileHandle;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -port => 3337,
);

# create exomes first
# get G2P genes 
# get 
# use gnomad, 1000 genomes
# fetch all protein coding genes and their location
# use location information to get variants from vcf
# mix 1000G and gnomAD
# create genotypes
# create individuals
# how many G2P genes
# GRCh37

my $dir = '/hps/nobackup2/production/ensembl/anja/G2P/test_data/';
my $ftp_dir = 'ftp://ftp.ensembl.org/pub/data_files/homo_sapiens/GRCh37/variation_genotype/';
#get_master_vcf();
sub get_master_vcf {
  # get all gene regions from 1000G files       
  
  my $fh = FileHandle->new("$dir/genes_grch37", 'r'); 
  my $out = FileHandle->new("$dir/master_1kg_grch37.vcf", 'w');
  print $out join("\t", '#CHROM', 'POS', 'ID', 'REF', 'ALT', 'QUAL', 'FILTER', 'INFO'), "\n";
  while (<$fh>) {
    chomp;
    my ($stable_id, $chr, $start, $end, $strand) = split;
    my $vcf_file = "$ftp_dir/ALL.chr$chr.phase3_shapeit2_mvncall_integrated_v3plus_nounphased.rsID.genotypes.vcf.gz";
    my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);
    $parser->seek($chr, $start, $end);
    while ($parser->next) {
      #CHROM POS     ID        REF ALT    QUAL FILTER INFO
      my $pos = $parser->get_raw_start;
      my $id = $parser->get_raw_IDs;
      my $raw_reference = $parser->get_raw_reference;
      my $raw_alternatives = $parser->get_raw_alternatives;
      print $out join("\t", $chr, $pos, $id, $raw_reference, $raw_alternatives, '.', '.', '.'), "\n";
    }
    $parser->close;
  }
  $fh->close;
  $out->close;
}
get_suspect_variant_vcf();
sub get_suspect_variant_vcf {
  my $fh = FileHandle->new("$dir/ddg2p_genes_mappings_23_04_2019.txt", 'r'); 
  my $out = FileHandle->new("$dir/suspect_gnomad_grch37.vcf", 'w');
  print $out join("\t", '#CHROM', 'POS', 'ID', 'REF', 'ALT', 'QUAL', 'FILTER', 'INFO'), "\n";
  while (<$fh>) {
    chomp;
    next if (/^Gene/);
#Gene stable ID  Chromosome/scaffold name  Gene start (bp) Gene end (bp) Strand  Gene name
    my ($stable_id, $chr, $start, $end, $strand, $gene_name) = split;
    next if (! grep {"$_" eq $chr} (1..22) );
    my $vcf_file = "$ftp_dir/gnomad/r2.1/exomes/gnomad.exomes.r2.1.sites.chr$chr\_noVEP.vcf.gz";
    my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);
    $parser->seek($chr, $start, $end);
    while ($parser->next) {
      #CHROM POS     ID        REF ALT    QUAL FILTER INFO
      my $pos = $parser->get_raw_start;
      my $id = $parser->get_raw_IDs;
      my $raw_reference = $parser->get_raw_reference;
      my $raw_alternatives = $parser->get_raw_alternatives;
      print $out join("\t", $chr, $pos, $id, $raw_reference, $raw_alternatives, '.', '.', '.'), "\n";
    }
    $parser->close;
  }
  $fh->close;
  $out->close;
}


#write_gene_regions();
sub write_gene_regions {
  my $gene_adaptor = $registry->get_adaptor('human', 'core', 'gene');
  my $genes = $gene_adaptor->fetch_all_by_biotype('protein_coding'); 
  my $fh = FileHandle->new("$dir/genes_grch37", 'w');
  foreach my $gene (@$genes) {
    next if (! grep {"$_" eq $gene->seq_region_name} (1..22) );
    print $fh join(" ", $gene->stable_id, $gene->seq_region_name, $gene->seq_region_start, $gene->seq_region_end, $gene->seq_region_strand), "\n";
  }
  $fh->close;
}

