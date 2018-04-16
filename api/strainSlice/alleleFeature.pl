use strict;
use warnings;
use Bio::EnsEMBL::Variation::DBSQL::StrainSliceAdaptor;
use Bio::EnsEMBL::MappedSliceContainer;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 91,
);

#T|T T 13753 13752 rs259200304


my $slice_adaptor = $registry->get_adaptor('mouse', 'core', 'slice');
#14:56901047:56902046:1
#my $slice = $slice_adaptor->fetch_by_region('chromosome', 14, 56901047, 56903046);
#my $slice = $slice_adaptor->fetch_by_region('chromosome', 14, 56902586, 56902633);

#my $slice = $slice_adaptor->fetch_by_region('chromosome', 14, 56902480, 56903046);
my $slice = $slice_adaptor->fetch_by_region('chromosome', 14, 56901510, 56901600);
#my $slice = $slice_adaptor->fetch_by_region('chromosome', 14, 56902483, 56902669);




my $af_adaptor = $registry->get_adaptor('mouse', 'variation', 'allelefeature');
$af_adaptor->db->use_vcf(1);
my $vdba = $registry->get_DBAdaptor('mouse', 'variation');

my $sample_adaptor = $registry->get_adaptor('mouse', 'variation', 'sample');

my $mgp_samples = $sample_adaptor->fetch_all_by_name('MGP:SPRET/EiJ');
my $sample = $mgp_samples->[0];

#my $afs = $af_adaptor->fetch_all_by_Slice($slice, $sample);



my $msc = Bio::EnsEMBL::MappedSliceContainer->new(-SLICE => $slice, -EXPANDED => 1);

$msc->set_StrainSliceAdaptor(Bio::EnsEMBL::Variation::DBSQL::StrainSliceAdaptor->new($vdba));


foreach my $strain_name ('MGP:A/J', 'MGP:SPRET/EiJ', 'MGP:WSB/EiJ') {
#foreach my $strain_name ('MGP:SPRET/EiJ') {

$msc->attach_StrainSlice($strain_name);
}

my $ref_slice = $msc->ref_slice;
print $ref_slice->seq(1), "\n";
print $msc->seq(1), "\n";

foreach (@{$msc->get_all_MappedSlices}) {
    my $slice = $_->get_all_Slice_Mapper_pairs->[0][0];
    print $slice->display_Slice_name, "\n"; 
    print $_->seq(1), "\n";
#    push @slices, {
#      name  => $slice->can('display_Slice_name') ? $slice->display_Slice_name : $config->{'species'},
#      slice => $slice,
#      seq   => $_->seq(1)
#    };
  }








