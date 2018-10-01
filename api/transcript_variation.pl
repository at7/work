use strict;
use warnings;
use Bio::EnsEMBL::Registry;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'mysql-eg-publicsql.ebi.ac.uk',
    -port => 4157);


my $transcript_adaptor = $registry->get_adaptor(
  'oryza_sativa',     # species
  'core', # database type
  'transcript'  # object type
);

my $transcript = $transcript_adaptor->fetch_by_stable_id('Os05t0113900-01');
print STDERR $transcript->stable_id, "\n";

my $tva = $registry->get_adaptor('oryza_sativa', 'variation', 'transcriptvariation');

my $tvs = $tva->fetch_all_by_Transcripts([$transcript]);
=begin
foreach my $tv (@$tvs) {

  print STDERR 'FEATURE ', $tv->feature, "\n";

  next if ($tv->display_consequence ne 'missense_variant');
  my $tvas = $tv->get_all_alternate_TranscriptVariationAlleles;
  foreach my $tv_allele (@$tvas) {
    print 'name ', $tv_allele->variation_feature->variation_name, "\n";
    my $sift_prediction = $tv_allele->polyphen_prediction || 'NA';
#    my $sift_score =  $tv_allele->sift_score;
    print "\n";
  }
}
#print scalar @$tvas, "\n";
=end
=cut

