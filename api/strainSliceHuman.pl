use strict;
use warnings;

use Bio::EnsEMBL::MappedSliceContainer;
use Bio::EnsEMBL::DBSQL::StrainSliceAdaptor;
use Bio::EnsEMBL::Registry;

my $reg = 'Bio::EnsEMBL::Registry';

$reg->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 91,
);


my $strain_slice_adaptor = $reg->get_adaptor('human', 'variation', 'StrainSlice');

my $slice_adaptor = $reg->get_adaptor('human', 'core', 'Slice');

my $slice = $slice_adaptor->fetch_by_region('chromosome', 1, 230710040, 230710080);

$strain_slice_adaptor->db->use_vcf(1);

my $strain_slice = $strain_slice_adaptor->get_by_strain_Slice("1000GENOMES:phase_3:NA19319", $slice);

print $slice->seq, "\n";

print $strain_slice->seq, "\n";


