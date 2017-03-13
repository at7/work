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
foreach my $name (qw/rs56117713 rs4846866/) {
  my $variation = $va->fetch_by_name($name);
  push @vfs, @{$variation->get_all_VariationFeatures};
}

my $ld_populations = $pa->fetch_all_LD_Populations;
foreach my $ld_population (@$ld_populations) {
  my @ld_values = @{$ldfca->fetch_by_VariationFeatures(\@vfs, $ld_population)->get_all_ld_values()};
  print scalar @ld_values, "\n";
}
