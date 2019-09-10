use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 97,
  -port => 3337,
);

my $species = 'homo_sapiens';
my $dir = '/hps/nobackup2/production/ensembl/anja/release_98/ld/';

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

my $population_adaptor = $vdba->get_PopulationAdaptor;
my $slice_adaptor = $cdba->get_SliceAdaptor;
my $vf_adaptor = $vdba->get_VariationFeatureAdaptor;
my $va = $vdba->get_VariationAdaptor;
my $population = $population_adaptor->fetch_by_name('1000GENOMES:phase_3:CEU');
my $ldFeatureContainerAdaptor = $vdba->get_LDFeatureContainerAdaptor;
$ldFeatureContainerAdaptor->db->use_vcf(1);
my $max_snp_distance = (500 / 2) * 1000;
$ldFeatureContainerAdaptor->max_snp_distance($max_snp_distance);
my $variation = $va->fetch_by_name('rs7707921');
my @vfs = grep { $_->slice->is_reference } @{$variation->get_all_VariationFeatures()};
my $vf = $vfs[0];
#my $start = 31065708;
#my $end = 31069708;
#my $slice = $slice_adaptor->fetch_by_region('chromosome', 6, $start, $end);
#my $vf_count = $vf_adaptor->count_by_Slice_constraint($slice);
#my $ldfc = $ldFeatureContainerAdaptor->fetch_by_Slice($slice, $population);

my $ldfc = $ldFeatureContainerAdaptor->fetch_by_VariationFeature($vf, $population);
my @ld_values = @{$ldfc->get_all_ld_values(1)};

my $variants = {};

foreach my $hash (@ld_values) {
#  last if (scalar keys %$variants > 10);
  my $variation1 = $hash->{variation_name1};
  my $variation2 = $hash->{variation_name2};
  $variants->{$variation1} = 1;
  $variants->{$variation2} = 1;
  my $r2 = $hash->{r2};
  my $d_prime = $hash->{d_prime};
  my $population_id = $hash->{population_id};
  print STDERR "$variation1 $variation2 $r2 $d_prime $population_id\n";
}

