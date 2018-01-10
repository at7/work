use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $species = 'mouse';
 
my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup/production/ensembl/anja/release_91/mouse/regulation_effect/ensembl.registry');
my $cdba = $registry->get_DBAdaptor($species, 'core');
my $fdba = $registry->get_DBAdaptor($species, 'funcgen');
my $vdba = $registry->get_DBAdaptor($species, 'variation');

my $rfa = $fdba->get_RegulatoryFeatureAdaptor or die 'Failed to get RegulatoryFeatureAdaptor';
my $mfa = $fdba->get_MotifFeatureAdaptor or die 'Failed to get MotifFeatureAdaptor';
my $fsa = $fdba->get_FeatureSetAdaptor or die 'Failed to get FeatureSetAdaptor';

my $sa = $cdba->get_SliceAdaptor or die 'Failed to get SliceAdaptor';

my $slices = $sa->fetch_all('toplevel', undef, 0, 1);

foreach my $slice (@$slices) {
my @rfs = @{$rfa->fetch_all_by_Slice($slice) || []};
}
