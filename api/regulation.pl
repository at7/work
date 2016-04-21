use strict;
use warnings;

use Bio::EnsEMBL::MappedSliceContainer;
use Bio::EnsEMBL::DBSQL::StrainSliceAdaptor;
use Bio::EnsEMBL::Registry;

my $reg = 'Bio::EnsEMBL::Registry';

$reg->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

my $va   = $reg->get_adaptor('human', 'variation', 'Variation');
my $vfa  = $reg->get_adaptor('human', 'variation', 'VariationFeature');
my $rfva = $reg->get_adaptor('human','variation','RegulatoryFeatureVariation');

my $variation_name = 'rs79160125';
my $v   = $va->fetch_by_name($variation_name);
my $vfs = $vfa->fetch_all_by_Variation($v);

my $rfvs = $rfva->fetch_all_by_VariationFeatures($vfs);
for my $rfv (@$rfvs) {
    print $rfv->regulatory_feature_stable_id, "\n";
}
