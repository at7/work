use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

my $species = 'homo_sapiens';


my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

my $pa = $vdba->get_PopulationAdaptor;
$pa->db->use_vcf(1);
my $ldfca = $vdba->get_LDFeatureContainerAdaptor;
my $va = $vdba->get_VariationAdaptor;

my @vfs = ();
foreach my $name (qw/rs552825750  rs142107873/) {
  my $variation = $va->fetch_by_name($name);
  push @vfs, @{$variation->get_all_VariationFeatures};
}

my $population = $pa->fetch_by_name('1000GENOMES:phase_3:CEU');
my $ld_populations = $pa->fetch_all_LD_Populations;

print STDERR scalar @$ld_populations, "\n";
foreach my $ld_population (@$ld_populations) {
  my @ld_values = @{$ldfca->fetch_by_VariationFeatures(\@vfs, $ld_population)->get_all_ld_values()};
  foreach my $hash (@ld_values) {
      my $vf1 = $hash->{'variation1'};
      my $vf2 = $hash->{'variation2'};
      my $variation1 = $hash->{variation_name1};
      my $variation2 = $hash->{variation_name2};
      my $r2 = $hash->{r2};
      my $d_prime = $hash->{d_prime};
      my $population_id = $hash->{population_id};
      print join(', ', '  ', $ld_population->name, $variation1, $variation2, $r2, $d_prime), "\n\n";

  }
}

my $slice_adaptor = $cdba->get_SliceAdaptor;
my $slice = $slice_adaptor->fetch_by_region('chromosome', 1, 230660048, 230760048);

my $ldfc = $ldfca->fetch_by_Slice($slice, $population);
