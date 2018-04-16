use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

my $tva = $registry->get_adaptor('human', 'variation', 'transcriptvariation');
my $vfa = $registry->get_adaptor('human', 'variation', 'variationfeature');
my $ta = $registry->get_adaptor('human', 'core', 'transcript');

my $stable_id = 'ENST00000468300';
my $transcript = $ta->fetch_by_stable_id($stable_id);

my $so_terms = ['3_prime_UTR_variant'];

my $transcript_variants = $tva->fetch_all_by_Transcripts_SO_terms([$transcript], $so_terms);

#foreach my $tv (@{$transcript_variants}) {
#  print $tv->display_consequence, "\n";
#}


my $vfs = $vfa->fetch_all_by_Slice_SO_terms($transcript->slice, $so_terms);
foreach my $vf (@$vfs) {
  print join(', ', @{$vf->consequence_type}), "\n";
}

