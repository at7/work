use strict;
use warnings;

use Bio::EnsEMBL::Registry;

use Data::Dumper;
use Bio::EnsEMBL::Variation::Utils::VEP qw(
  parse_line
);

my $species = 'human';
 
my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_94/ensembl_vep_cache_testdata/ensembl.registry.20180725');
#$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_94/ensembl_vep_cache_testdata/ensembl.registry');

my $cdba = $registry->get_DBAdaptor($species, 'core');
my $fdba = $registry->get_DBAdaptor($species, 'funcgen');
my $vdba = $registry->get_DBAdaptor($species, 'variation');

my $rfa = $fdba->get_RegulatoryFeatureAdaptor or die 'Failed to get RegulatoryFeatureAdaptor';
my $mfa = $fdba->get_MotifFeatureAdaptor or die 'Failed to get MotifFeatureAdaptor';

my $bmfa = $fdba->get_BindingMatrixFrequenciesAdaptor or die 'Failed to get BindingMatrixFrequencies';

my $sa = $cdba->get_SliceAdaptor or die 'Failed to get SliceAdaptor';
my $mfva = $vdba->get_MotifFeatureVariationAdaptor or die 'Failed to get MotifFeatureVariationAdaptor';
my $vfa = $vdba->get_VariationFeatureAdaptor or die 'Failed to get VariationFeatureAdaptor';

my $slice = $sa->fetch_by_region('chromosome', 7,);

#7 151409212 151409212
my $vf = Bio::EnsEMBL::Variation::VariationFeature->new(
  -start => 151409215,
  -end =>   151409215,
  -slice => $slice,           # the variation must be attached to a slice
  -allele_string => 'C/T',    # the first allele should be the reference allele
  -strand => 1,
  -map_weight => 1,
  -adaptor => $vfa,           # we must attach a variation feature adaptor
  -variation_name => 'newSNP',
);
my $vfos = $vf->get_all_VariationFeatureOverlaps;
foreach (@$vfos) {
  print STDERR $_, "\n";
  if($_->isa('Bio::EnsEMBL::Variation::MotifFeatureVariation')) {
    my $mf = $_->motif_feature;
    next unless $mf->stable_id;
    for my $allele (@{ $_->get_all_alternate_VariationFeatureOverlapAlleles }) {
      print join(' ',
            'overlap',
            $vf->variation_name, 
            $_->motif_feature->stable_id,
            $_->motif_feature->binding_matrix->stable_id, 
            $allele->motif_start,
            $allele->motif_end,
            $allele->motif_score_delta,
            $allele->in_informative_position,
      ), "\n";
    }
  }
}


my $mfs = $mfa->fetch_all_by_Slice($slice);
foreach my $motif_feature (@$mfs) {
  next unless $motif_feature->stable_id;
  print $motif_feature->stable_id, "\n";
  my $mfv = Bio::EnsEMBL::Variation::MotifFeatureVariation->new(
    -motif_feature      => $motif_feature,
    -variation_feature  => $vf,
    -adaptor            => $mfva,
    -disambiguate_single_nucleotide_alleles => 1,
  );
  for my $allele (@{ $mfv->get_all_alternate_MotifFeatureVariationAlleles }) {
      print join(' ',
            'adaptor ',
            $vf->variation_name, 
            $mfv->motif_feature->stable_id,
            $mfv->motif_feature->binding_matrix->stable_id, 
            $allele->motif_start,
            $allele->motif_end,
            $allele->motif_score_delta,
            $allele->in_informative_position,
      ), "\n";
    }
}


