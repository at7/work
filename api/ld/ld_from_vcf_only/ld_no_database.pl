use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::Registry;


my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'mysql-ens-mirror-1',
  -port => 4240,
  -user => 'ensro',
  -DB_version => 96,
);


my @insertions = qw/

/;


my $vfa = $registry->get_adaptor('human', 'variation', 'variationFeature');
my $ldfca = $registry->get_adaptor('human', 'variation', 'LDFeatureContainer');
my $pa = $registry->get_adaptor('human', 'variation', 'population');

my $population = $pa->fetch_by_name('1000GENOMES:phase_3:CEU');

$vfa->db->use_vcf(1);
my $sa = $registry->get_adaptor('human', 'core', 'slice');

my $va = $registry->get_adaptor('human', 'variation', 'variation');
my $vf = $va->fetch_by_name('rs149005702')->get_all_VariationFeatures->[0];

my $ldfc = $ldfca->fetch_by_VariationFeature($vf, $population);
my @ld_values = @{$ldfc->get_all_ld_values()};
foreach my $hash (@ld_values) {
    my $vf1 = $hash->{'variation1'};
    my $vf2 = $hash->{'variation2'};
    my $variation1 = $hash->{variation_name1};
    my $variation2 = $hash->{variation_name2};
    my $r2 = $hash->{r2};
    my $d_prime = $hash->{d_prime};
    print join(', ', $vf1, $vf2, $variation1, $variation2, $r2, $d_prime), "\n\n";
}
