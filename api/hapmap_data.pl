use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

#my $registry_file = 'ensembl.registry';
my $species = 'homo_sapiens';
$species = 'human';
#$registry->load_all($registry_file);

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

my $population_adaptor = $vdba->get_PopulationAdaptor;
my $variation_adaptor = $vdba->get_VariationAdaptor;



sub print_allele_frequency {





}


sub print_hapmap_sample_counts {
  # all hapmap populations
  my $hapmap_populations = $population_adaptor->fetch_all_HapMap_Populations;
  foreach my $population (@$hapmap_populations) {
    print STDERR $population->name, "\n";
  }
  my @all_hapmap_populations = (
  'BROAD_NHGRI_T2D:HapMap-CEU',
  'CSHL-HAPMAP:HAPMAP-ASW',
  'CSHL-HAPMAP:HapMap-CEU',
  'CSHL-HAPMAP:HAPMAP-CHB',
  'CSHL-HAPMAP:HAPMAP-CHD',
  'CSHL-HAPMAP:HAPMAP-GIH',
  'CSHL-HAPMAP:HapMap-HCB',
  'CSHL-HAPMAP:HapMap-JPT',
  'CSHL-HAPMAP:HAPMAP-LWK',
  'CSHL-HAPMAP:HAPMAP-MEX',
  'CSHL-HAPMAP:HAPMAP-MKK',
  'CSHL-HAPMAP:HAPMAP-TSI',
  'CSHL-HAPMAP:HapMap-YRI',
  'CSHL-HAPMAP:JPT+CHB',
  'JDRF_WT_DIL:32 Hapmap CEPHS',
  'LTG_NCI_NIH:HapMap populations (CEU, CHB/JPT and YRI)',
  'LTG_NCI_NIH:HapMap samples',
  'LTG_NCI_NIH:LTG_NCI_NIH-HapMap-CEU',
  'LTG_NCI_NIH:LTG_NCI_NIH-HapMap-CHB_JPT',
  'LTG_NCI_NIH:LTG_NCI_NIH-HapMap-YRI',
  'PSYCHMEDCARDIFF:HAPMAP-CEU',
  'SEATTLESEQ:Eight-Hapmap-Samples',
  'VU_JRS:CSHL-HAPMAP_HapMap-HCB',);

  foreach my $name (@all_hapmap_populations) {
    my $population = $population_adaptor->fetch_by_name($name);
    my @samples = @{$population->get_all_Samples};
    print STDERR "$name ", scalar @samples, "\n";
  }
}












# get hapmap populations



