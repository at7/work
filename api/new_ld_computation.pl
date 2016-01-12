use strict;
use warnings;

my $start_time = time;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 83,
);

my $species = 'human';

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');
#$vdba->use_vcf(1);

my $population_adaptor = $vdba->get_PopulationAdaptor;
my $slice_adaptor = $cdba->get_SliceAdaptor;
my $ldFeatureContainerAdaptor = $vdba->get_LDFeatureContainerAdaptor;
my $variation_adaptor = $vdba->get_VariationAdaptor;

my $chr = 7;
my $start = 48_700_000;
#my $end   = 48_800_000;
my $end   = 48_950_000;

my $population_name = '1000GENOMES:phase_3:ACB'; #we only want LD in this population
my $population = $population_adaptor->fetch_by_name($population_name); #get population object from database

print "fetch_by_Slice use VCF\n";
my $slice = $slice_adaptor->fetch_by_region('chromosome',$chr,$start,$end); #get slice of the region
$ldFeatureContainerAdaptor->db->use_vcf(1);
my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_Slice($slice, $population);
#print_container_content($ldFeatureContainer);

sub print_container_content {
  my $ldFeatureContainer = shift;
  print "Name ", $ldFeatureContainer->name, "\n";
  my @variations = @{$ldFeatureContainer->get_variations()};
  print "Variations: ", scalar @variations, "\n";
  my @ld_values = @{$ldFeatureContainer->get_all_ld_values}; 
  print "LD values: ", scalar @ld_values, "\n"; 
  my @r_square_values = @{$ldFeatureContainer->get_all_r_square_values}; 
  print "R square values: ", scalar @r_square_values, "\n";
  my @d_prime_values = @{$ldFeatureContainer->get_all_d_prime_values};
  print "D prime values: ", scalar @d_prime_values, "\n"; 
  my $count = count_ld_values($ldFeatureContainer);
  print "LD count $count\n";
}

sub count_ld_values {
  my $container = shift;
  my $ld_values = 0;
  foreach my $key (keys %{$container->{'ldContainer'}}) {
    $ld_values += keys %{$container->{'ldContainer'}->{$key}};
  }
  return $ld_values;
}

my $duration = time - $start_time;
print "Execution time: $duration s\n";
=begin
-> fetch_by_Slice
  -> _fetch_by_Slice_VCF
    -> _get_all_LD_genotypes_by_Slice (VCFCollection_::_get_all_LD_genotypes_by_Slice_DEV)
      -> _objs_from_sth_vcf:
        alleles_variation:
          $alleles_variation{$snp_start}->{$pop_id}->{$gt[0]}++;
          $alleles_variation{$snp_start}->{$pop_id}->{$gt[1]}++;
          '48903201' => {
                          '373508' => {
                                        'T' => 11,
                                        'C' => 181
                                      }
                        },
          '48902790' => {
                          '373508' => {
                                        'G' => 192
                                      }
        sample_information:  
          $sample_information{$pop_id}->{$snp_start}->{$sample_id}->{allele_1} = $gt[0];
          $sample_information{$pop_id}->{$snp_start}->{$sample_id}->{allele_2} = $gt[1];                        },
          '48902612' => {
                          '33' => {
                              'allele_2' => 'C',
                              'allele_1' => 'C'
                            },
                          '32' => {
                              'allele_2' => 'C',
                              'allele_1' => 'C'
                            },

  -> _ld_calc



vc_genotypes:
  },
  '48903279' => {
                  'HG02108' => 'AA',
                  'HG02476' => 'AA',
                  'HG02479' => 'AA',
                  'HG01896' => 'AA',
                  'HG02144' => 'AA',
                  'HG02433' => 'AA',
                  'HG02557' => 'AA',
                  'HG01883' => 'AA',
                  'HG02308' => 'AA',

#if the variation has 2 alleles, print all the genotypes to the file
0 48903756  48903756  373508  69  AA
0 48903756  48903756  373508  59  aa
0 48903756  48903756  373508  49  Aa
0 48903756  48903756  373508  24  Aa


- inlcude failed variants 
=end
=cut














