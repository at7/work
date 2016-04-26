use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Data::Dumper;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous'
);

my $species = 'homo_sapiens';

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

my $slice_adaptor = $cdba->get_SliceAdaptor;

my $population_adaptor = $vdba->get_PopulationAdaptor;
my $ldFeatureContainerAdaptor = $vdba->get_LDFeatureContainerAdaptor;
$ldFeatureContainerAdaptor->db->use_vcf(1);

my $max_snp_distance = 500_000;
$ldFeatureContainerAdaptor->max_snp_distance($max_snp_distance);

my $variation_adaptor = $vdba->get_VariationAdaptor;
my $vfa = $vdba->get_VariationFeatureAdaptor;

my $data = {
  human => {
    variants => ['rs1042779', 'rs611646'],
    populations => [
      '1000GENOMES:phase_3:KHV',
    ],
    regions => [
      { chr => 6, start => 25_837_556, end => 25_843_455},
      { chr => 7, start => 48_902_556, end => 48_903_891},
      { chr => 1, start => 3_214_482, end => 3_315_000 },
      { chr => 1, start => 3_214_482, end => 3_671_498 },
    ],
    species => 'homo_sapiens',
  },
};

my $names_only = 0;

my $population_name = $data->{'human'}->{populations}->[0];
my $population = $population_adaptor->fetch_by_name($population_name);

my $variant_name = $data->{'human'}->{variants}->[0];
my $variant = $variation_adaptor->fetch_by_name($variant_name);

my $region = $data->{'human'}->{regions}->[0];
my $slice = $slice_adaptor->fetch_by_region('chromosome', $region->{chr}, $region->{start}, $region->{end});


my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_Slice($slice, $population);
my @ld_values = @{$ldFeatureContainer->get_all_ld_values($names_only)}; 


foreach my $ld (@ld_values) {
  while (my ($key, $value) = each %$ld) {
    print $key, ' ', $value, "\n";
  }
  print "\n";
}







