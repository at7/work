use strict;
use warnings;

use Bio::EnsEMBL::Registry;
my $registry = 'Bio::EnsEMBL::Registry';


use Data::Dumper qw(Dumper);
 

my $species = $ARGV[0];
my $population_name = $ARGV[1]; 

$registry->load_all("/hps/nobackup/production/ensembl/anja/release_92/$species/ensembl.registry");


my $slice_adaptor = $registry->get_adaptor($species, 'core', 'slice');
my $slice = $slice_adaptor->fetch_by_region('chromosome', 12, 8_100_223, 8_200_223);

my $sample_genotype_feature_adaptor = $registry->get_adaptor($species, 'variation', 'samplegenotypefeature');
$sample_genotype_feature_adaptor->db->use_vcf(1);

my $population_genotype_adaptor = $registry->get_adaptor($species, 'variation', 'populationgenotype');

my $vca = $registry->get_adaptor($species, 'variation', 'vcfcollection');

my $vfa = $registry->get_adaptor($species, 'variation', 'variationfeature');


#my $sample_adaptor = $registry->get_adaptor($species, 'variation', 'sample');
my $population_adaptor = $registry->get_adaptor($species, 'variation', 'population');
#my $vfa = $registry->get_adaptor($species, 'variation', 'variationfeature');


my $vcf_collections = $vca->fetch_all;

foreach my $collection (@$vcf_collections) {
  print $collection->id, "\n";
}

my $calculate_ld = 0;
if ($calculate_ld) {
  my $ld_populations = $population_adaptor->fetch_all_LD_Populations;
  print STDERR 'LD populations ', scalar @$ld_populations, "\n"; 


  my $population = $population_adaptor->fetch_by_name($population_name);
  my $samples = $population->get_all_Samples;
  print STDERR scalar @$samples, "\n";


  my $ldfca = $registry->get_adaptor($species, 'variation', 'ldfeaturecontainer');
  my $ldfc = $ldfca->fetch_by_Slice($slice, $population);

  foreach my $ld (@{$ldfc->get_all_ld_values}) {
    print STDERR $ld->r2, "\n";
  }
}

my $print_genotypes = 1;
if ($print_genotypes) {
  my $population;
  if ($population_name) {
    $population = $population_adaptor->fetch_by_name($population_name);
  }
  my $vfs = $vfa->fetch_all_by_Slice($slice);
  foreach my $vf (@$vfs) {
    my $v = $vf->variation;
    my $pgts;
    if ($population) {
      $pgts = $v->get_all_PopulationGenotypes($population);
    } else {
      $pgts = $v->get_all_PopulationGenotypes();
    }
    foreach my $pgt (@$pgts) {
      print STDERR $v->name, ' ', $pgt->population->name, ' ', $pgt->genotype_string, ' ', $pgt->frequency, "\n";
    }
  }
}



