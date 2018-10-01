use strict;
use warnings;

use Bio::EnsEMBL::Registry;

use Data::Dumper;

my $species = 'human';
 
my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_94/human/ensembl.registry');

my $cdba = $registry->get_DBAdaptor($species, 'core');
my $fdba = $registry->get_DBAdaptor($species, 'funcgen');
my $vdba = $registry->get_DBAdaptor($species, 'variation');

my $rfa = $fdba->get_RegulatoryFeatureAdaptor or die 'Failed to get RegulatoryFeatureAdaptor';
my $mfa = $fdba->get_MotifFeatureAdaptor or die 'Failed to get MotifFeatureAdaptor';

my $bmfa = $fdba->get_BindingMatrixFrequenciesAdaptor or die 'Failed to get BindingMatrixFrequencies';

my $sa = $cdba->get_SliceAdaptor or die 'Failed to get SliceAdaptor';
my $mfva = $vdba->get_MotifFeatureVariationAdaptor or die 'Failed to get MotifFeatureVariationAdaptor';
my $vfa = $vdba->get_VariationFeatureAdaptor or die 'Failed to get VariationFeatureAdaptor';

my $slice = $sa->fetch_by_region('chromosome', 3, 100100019, 100101119);

my $vfs = $vfa->fetch_all_by_Slice($slice);

foreach my $vf (@$vfs) {
  my $mfvs = $vf->get_all_MotifFeatureVariations;
  print $vf->variation_name, ' ', scalar @$mfvs, "\n";
}

#$mfa = Bio::EnsEMBL::DBSQL::MergedAdaptor->new(
#  -species  => $vfa->db->species,
#  -type     => 'MotifFeature',
#);

#my $mfs = $mfa->fetch_all_by_Slice($slice);
#print scalar @$mfs, "\n";
