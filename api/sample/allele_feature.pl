use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
-host => 'ensembldb.ensembl.org',
-user => 'anonymous'
);

my $slice_adaptor = $registry->get_adaptor('mus_musculus', 'core', 'slice');

my $variation_adaptor = $registry->get_adaptor('mus_musculus', 'variation', 'variation');
$variation_adaptor->db->use_vcf(1);

my $af_adaptor = $registry->get_adaptor('mus_musculus', 'variation', 'allelefeature'); 
my $sample_adaptor = $registry->get_adaptor('mus_musculus', 'variation', 'sample');
my $strain_slice_adaptor = $registry->get_adaptor('', 'variation', 'strainslice');

# slice Chromosome 11: 101,170,523-101,190,724 
# strain MGP:A/J
# BaseFeature vf.display =1 AND vf.seq_region_id IN (20606) AND vf.seq_region_start <= 101190724 AND vf.seq_region_end >= 101170523 AND vf.seq_region_start >= 101170023
my $slice = $slice_adaptor->fetch_by_region('chromosome', 11, 101_170_523, 101_190_724);

my $strain = $sample_adaptor->fetch_all_by_name('MGP:A/J')->[0];

my $afs = $af_adaptor->fetch_all_by_Slice($slice, $strain);


my $msc = Bio::EnsEMBL::MappedSliceContainer->new(-SLICE => $ref_slice_obj, -EXPANDED => 1);

$msc->set_StrainSliceAdaptor(Bio::EnsEMBL::Variation::DBSQL::StrainSliceAdaptor->new($vdb));

$msc->attach_StrainSlice($_) for @$samples;

my @slices = ({
  name  => $config->{'ref_slice_name'},
  slice => $ref_slice_obj
});

foreach (@{$msc->get_all_MappedSlices}) {
  my $slice = $_->get_all_Slice_Mapper_pairs->[0][0];

  push @slices, {
    name  => $slice->can('display_Slice_name') ? $slice->display_Slice_name : $config->{'species'},
    slice => $slice,
    seq   => $_->seq(1)
  };
}


#print scalar @$afs, "\n";

#foreach (@$afs) {
#  print $_->variation->name, "\n";
#  print $_->allele_string, "\n";
#  print $_->length_diff, "\n";  
#  print $_->length, "\n";
#}

