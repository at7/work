use strict;
use warnings;

use Bio::EnsEMBL::MappedSliceContainer;
use Bio::EnsEMBL::Variation::DBSQL::StrainSliceAdaptor;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 83,
);

my $slice_adaptor = $registry->get_adaptor('mouse', 'core', 'slice');

my $af_adaptor = $registry->get_adaptor('mouse', 'variation', 'allelefeature');
my $variation_adaptor = $registry->get_DBAdaptor('mouse', 'variation');
my $vf_adaptor = $registry->get_adaptor('mouse', 'variation', 'variationfeature'); 
my $v_adaptor = $registry->get_adaptor('mouse', 'variation', 'variation');
my $strain_slice_adaptor = $registry->get_adaptor('mouse', 'variation', 'strainslice');
my $sample_adaptor = $registry->get_adaptor('mouse', 'variation', 'sample');
my $sg_adaptor = $registry->get_adaptor('mouse', 'variation', 'samplegenotype');
$sg_adaptor->db->use_vcf(1);


my $slice = $slice_adaptor->fetch_by_region('chromosome', 14, 56887795, 56962579);

my $mgp_samples = $sample_adaptor->fetch_all_by_name('MGP:A/J');
my $sample = $mgp_samples->[0];

my $msc = Bio::EnsEMBL::MappedSliceContainer->new(-SLICE => $slice, -EXPANDED => 1);
#$msc->set_StrainSliceAdaptor($strain_slice_adaptor);
#$msc->attach_StrainSlice($_) for @$mgp_samples;

new_strain_slice($slice, $sample->name);
print_allele_features($slice, $sample);
print_sample_genotypes($slice);
fetch_GT_by_variation();

sub new_strain_slice {
  my $slice = shift;
  my $strain_name = shift;
  my $strain_slice = Bio::EnsEMBL::Variation::StrainSlice->new(
    -START   => $slice->{'start'},
    -END     => $slice->{'end'},
    -STRAND  => $slice->{'strand'},
    -ADAPTOR => $slice->adaptor(),
    -SEQ     => $slice->{'seq'},
    -SEQ_REGION_NAME => $slice->{'seq_region_name'},
    -SEQ_REGION_LENGTH => $slice->{'seq_region_length'},
    -COORD_SYSTEM    => $slice->{'coord_system'},
    -STRAIN_NAME     => $strain_name
  );

#  my $strain_slice = $slice->get_by_strain($sample->name);
  my $afs = $strain_slice->get_all_AlleleFeatures();
  print 'get_all_AlleleFeatures ', scalar @$afs, "\n";
}

sub print_allele_features {
  my $slice = shift;
  my $sample = shift;
  # adaptor, source, _sample_id, slice, end, _vf_allele_string, _variation_id, strand, sample, variation_name, overlap_consequences, _variation_feature_id, allele_string, start
  my $afs = $af_adaptor->fetch_all_by_Slice($slice, $sample);
  print 'print_allele_features ', scalar @$afs, "\n";

  foreach my $af (@$afs) {
    my $start = $af->start;
    my $end = $af->end;
    my $allele_string  = $af->allele_string;
    my $vf_allele_string = $af->{_vf_allele_string};
    my $sample = $af->sample;
    my $sample_name = $sample->name;
    my $variation_name = $af->variation_name;
#    print "$start $end $allele_string $vf_allele_string $sample_name $variation_name\n";
  }
}

sub print_sample_genotypes {
  my $slice = shift;
  my $vfs = $vf_adaptor->fetch_all_by_Slice($slice);
#  foreach my $vf (@$vfs) {
#    my $variant = $vf->variation();
#    my $variant_name = $variant->name;
#    my $genotypes = $sg_adaptor->fetch_all_by_Variation($variant);
#    if (scalar @$genotypes > 0) {
#      print $variant_name, ' ', scalar @$genotypes, "\n";
#    }
#  }
}

sub fetch_GT_by_variation {
  my $variant_name = 'rs49979499';
  my $variation = $v_adaptor->fetch_by_name($variant_name);
  my $genotypes = $sg_adaptor->fetch_all_by_Variation($variation);
  foreach my $genotype (@$genotypes) {
    print $genotype->sample->name, ' ', $genotype->sample->dbID, "\n";
  }
}

#my $afs = $af_adaptor->fetch_all_by_Slice($slice, $sample);
#print scalar @$afs, "\n";

# sample_genotype_adaptor fetch_all_by_Variation

=begin

MGP:129P2/OlaHsd
MGP:129S1/SvImJ
MGP:129S5SvEvBrd
MGP:A/J
MGP:AKR/J
MGP:BALB/cJ
MGP:C3H/HeJ
MGP:C57BL/6NJ
MGP:CAST/EiJ
MGP:CBA/J
MGP:DBA/2J
MGP:FVB/NJ
MGP:LP/J
MGP:NOD/ShiLtJ
MGP:NZO/HILtJ
MGP:PWK/PhJ
MGP:SPRET/EiJ
MGP:WSB/EiJ




my $strain_name = 'VENTER';
my $strainSlice = $slice->get_by_strain($strain_name);

# get allele features between this StrainSlice and the reference
my $afs = $strainSlice->get_all_AlleleFeatures_Slice();
foreach my $af ( @{$afs} ) {
  print "AlleleFeature in position ", $af->start, "-", $af->end, " in strain with allele ", $af->allele_string, "\n";
}

# compare a strain against another strain
my $strain_name_2 = 'WATSON';

my $strainSlice_2 = $slice->get_by_strain($strain_name_2);
my $differences = $strainSlice->get_all_differences_StrainSlice($strainSlice_2);
foreach my $difference ( @{$differences} ) {
  print "Difference in position ", $difference->start, "-", $difference->end(), " in strain with allele ", $difference->allele_string(), "\n";
}
#$strainSlice-> get_all_AlleleFeatures_Slice()

=end
=cut



