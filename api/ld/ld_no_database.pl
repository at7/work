use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::Registry;


my $species = 'vervet';

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_97/vervet/ensembl.registry');

my $vfa = $registry->get_adaptor('vervet', 'variation', 'variationFeature');
my $ldfca = $registry->get_adaptor('vervet', 'variation', 'LDFeatureContainer');
$vfa->db->use_vcf(1);
my $sa = $registry->get_adaptor('vervet', 'core', 'slice');

#my $slice = $sa->fetch_by_region('chromosome', 11, 6780282, 6907410);
my $slice = $sa->fetch_by_region('chromosome', 11, 6780282, 6782282);

my $vfs = $vfa->fetch_all_by_Slice($slice);

print scalar @$vfs, "\n";

my $ldfc = $ldfca->fetch_by_Slice($slice);

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

