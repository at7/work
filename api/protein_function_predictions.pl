use strict;
use warnings;

use Bio::EnsEMBL::Registry;


my $registry = 'Bio::EnsEMBL::Registry';
my $file = '';
$registry->load_all($file);

my $transcript_adaptor = $registry->get_adaptor('human', 'core', 'transcript');
my $transcript = $transcript_adaptor->fetch_by_stable_id('ENST00000299335.7');

my $tva = $registry->get_adaptor('human', 'variation', 'transcriptvariation');

my $tvs = $tva->fetch_all_by_Transcripts_SO_terms([$transcript], ['missense_variant']);

foreach my $tv (@$tvs) {
  foreach my $tv_allele (@{$tv->get_all_alternate_TranscriptVariationAlleles}) {
    my $cadd_score = $tv_allele->dbnsfp_cadd_score || 'No CADD score';
    my $cadd_prediction = $tv_allele->dbnsfp_cadd_prediction || 'No CADD prediction';
    my $sift_score = $tv_allele->sift_score;
    my $sift_prediction = $tv_allele->sift_prediction;
    my $polyphen_score = $tv_allele->polyphen_score;
    my $polyphen_prediction = $tv_allele->polyphen_prediction;
    print STDERR "$cadd_score $cadd_prediction $sift_score $sift_prediction $polyphen_score $polyphen_prediction\n";
  }
}

print scalar @$tvs, "\n";


