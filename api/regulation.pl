use strict;
use warnings;

use Bio::EnsEMBL::MappedSliceContainer;
use Bio::EnsEMBL::DBSQL::StrainSliceAdaptor;
use Bio::EnsEMBL::Registry;

my $reg = 'Bio::EnsEMBL::Registry';


$reg->load_all('/lustre/scratch110/ensembl/at7/release_86/human/ensembl.registry');

#$reg->load_registry_from_db(
#  -host => 'ensembldb.ensembl.org',
#  -user => 'anonymous',
#);

my $va   = $reg->get_adaptor('human', 'variation', 'Variation');
my $vfa  = $reg->get_adaptor('human', 'variation', 'VariationFeature');
my $rfva = $reg->get_adaptor('human','variation','RegulatoryFeatureVariation');
my $rfa = $reg->get_adaptor('human','regulation','RegulatoryFeature');
my $sa = $reg->get_adaptor('human', 'core', 'Slice');



=begin
my $variation_name = 'rs79160125';
my $v   = $va->fetch_by_name($variation_name);
my $vfs = $vfa->fetch_all_by_Variation($v);

my $rfvs = $rfva->fetch_all_by_VariationFeatures($vfs);
for my $rfv (@$rfvs) {
    print $rfv->regulatory_feature_stable_id, "\n";
}


my $rf_stable_id = 'ENSR00000316845';
my $rf           = $rfa->fetch_by_stable_id($rf_stable_id);
print $rf, "\n";
# fetch all RegulatoryFeatureVariations falling in the MotifFeature
$rfvs = $rfva->fetch_all_by_RegulatoryFeatures([$rf]);
print scalar @$rfvs, "\n";
=end
=cut


my $slice = $sa->fetch_by_region('chromosome', 20);
my $rfs = $rfa->fetch_all_by_Slice($slice);
print STDERR scalar @$rfs, "\n";
