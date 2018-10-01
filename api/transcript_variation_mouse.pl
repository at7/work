use strict;
use warnings;
use Bio::EnsEMBL::Registry;
my $registry = 'Bio::EnsEMBL::Registry';


$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -release => 91,
);
my $transcript_adaptor = $registry->get_adaptor(
  'mouse',     # species
  'core', # database type
  'transcript'  # object type
);

my $transcript = $transcript_adaptor->fetch_by_stable_id('ENSMUST00000062934.6');

my $tva = $registry->get_adaptor('mouse', 'variation', 'transcriptvariation');

my $tvs = $tva->fetch_all_by_Transcripts([$transcript]);
foreach my $tv (@$tvs) {
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


