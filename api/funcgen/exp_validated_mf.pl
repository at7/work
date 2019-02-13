#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);
use Bio::EnsEMBL::Funcgen::DBSQL::DBAdaptor;
use Data::Dumper;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 95,
);


my $slice_adaptor = $registry->get_adaptor('human', 'core', 'slice');
my $slice = $slice_adaptor->fetch_by_region( 'chromosome', '10', 102456350, 103456387);


my $regulatory_feature_adaptor = $registry->get_adaptor('human', 'funcgen', 'regulatoryfeature');

my $regulatory_features = $regulatory_feature_adaptor->fetch_all_by_Slice($slice);

print  $regulatory_features, "\n";
print 'Regulatory Feature for region 13:32314000-32317500 ', scalar @$regulatory_features, "\n"; 

foreach my $rf (@$regulatory_features) {
  my $motif_features = $rf->fetch_all_MotifFeatures_with_matching_Peak();
  print 'Experimentally validated Motif Features ', scalar @$motif_features, "\n";
  foreach my $mf (@$motif_features) {
    my $binding_matrix = $mf->binding_matrix;
    my $binding_matrix_stable_id = $mf->stable_id;
    my $transcription_factors = $binding_matrix->get_TranscriptionFactorComplex_names;
    my $tf_label = join ",", @{$transcription_factors};
    print 'Binding matrix and TFs ', $binding_matrix_stable_id, ' ', join(', ', @$transcription_factors), "\n";
    my @epigenomes = sort map { $_->fetch_PeakCalling->fetch_Epigenome->name } @{$mf->fetch_all_overlapping_Peaks};
    print 'Epigenomes ', join(', ', @epigenomes), "\n"; 
    #my @peak_lables = sort map { $_->fetch_PeakCalling->display_label } @{$mf->fetch_all_overlapping_Peaks};
    #print 'Peak lables ', join(', ', @peak_lables), "\n"; 
  }
}

# rs570548398
my $mfa = $registry->get_adaptor('human', 'funcgen', 'MotifFeature');
my $mfva = $registry->get_adaptor('human', 'variation', 'MotifFeatureVariation');
my $feature_id = 'ENSM00000013722';
my $motif_feature = $mfa->fetch_by_stable_id($feature_id) or die "Failed to fetch MotifFeature for id: $feature_id";

#print Dumper($motif_feature), "\n";


$mfva->db->include_failed_variations(1);

$slice = $slice_adaptor->fetch_by_Feature($motif_feature) or die "Failed to get slice around motif feature: " . $motif_feature->dbID;

for my $vf ( @{ $slice->get_all_VariationFeatures }, @{ $slice->get_all_somatic_VariationFeatures } ) {
    print $vf->variation_name, "\n";
    my $mfv = Bio::EnsEMBL::Variation::MotifFeatureVariation->new(
        -motif_feature      => $motif_feature,
        -variation_feature  => $vf,
        -adaptor            => $mfva,
        -disambiguate_single_nucleotide_alleles => 1,
    );

  

  for my $allele (@{ $mfv->get_all_alternate_MotifFeatureVariationAlleles }) {
    print join(' ', 
            $allele->motif_start,
            $allele->motif_end,
            $allele->motif_score_delta,
            $allele->in_informative_position,
    ), "\n";
  }

}
#print '>> ', Dumper($motif_feature), "\n";


my $binding_matrix_adaptor = $registry->get_adaptor('human', 'funcgen', 'BindingMatrix');
my $binding_matrices = $binding_matrix_adaptor->fetch_all;
print 'BindingMatrices ', scalar @$binding_matrices, "\n"; 



foreach my $bm (@$binding_matrices) {
  print Dumper($bm), "\n";
  print Dumper($bm->summary_as_hash), "\n";
}



