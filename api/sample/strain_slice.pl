use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::MappedSliceContainer;
use Bio::EnsEMBL::Variation::DBSQL::StrainSliceAdaptor;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
-host => 'ensembldb.ensembl.org',
-user => 'anonymous'
);

my $species = 'mus_musculus';
my $strain_name = 'MGP:A/J';
#'1000GENOMES:phase_3:HG00122'
my $slice_adaptor = $registry->get_adaptor($species, 'core', 'slice');

my $vdb = $registry->get_DBAdaptor($species, 'variation');
my $variation_adaptor = $registry->get_adaptor($species, 'variation', 'variation');
$variation_adaptor->db->use_vcf(1);

#my $slice = $slice_adaptor->fetch_by_region('chromosome', '2', 45183422, 45183442);
my $slice = $slice_adaptor->fetch_by_region('chromosome', '11', 101187846, 101187876);


print "Slice length ", $slice->length, "\n";
print "Slice seq ", $slice->seq, "\n";

my $msc = Bio::EnsEMBL::MappedSliceContainer->new(-SLICE => $slice, -EXPANDED => 1);

$msc->set_StrainSliceAdaptor(Bio::EnsEMBL::Variation::DBSQL::StrainSliceAdaptor->new($vdb));

$msc->attach_StrainSlice($strain_name);


#$mapped_slices = $strain_slice_adaptor->fetch_by_name($msc, '1000GENOMES:phase_3:HG00096');
#$mapped_slice = $mapped_slices->[0];
#my $seq = $mapped_slice->seq(1);
#print "Mapped Slice length ", length $seq, "\n";
#ok( length $seq == 19727, 'mapped_slice length');

foreach (@{$msc->get_all_MappedSlices}) {
  my $slice = $_->get_all_Slice_Mapper_pairs->[0][0];
  print $_->seq(1), "\n";
  print length $slice, "\n";
  print $slice->seq, "\n";

#  push @slices, {
#    name  => $slice->can('display_Slice_name') ? $slice->display_Slice_name : $config->{'species'},
#    slice => $slice,
#    seq   => $_->seq(1)
#  };
}



