#!/usr/bin/env perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_96/human/vep_dumps/ensembl.registry');

my $slice_adaptor = $registry->get_adaptor('human', 'core', 'slice');
my $slice = $slice_adaptor->fetch_by_region( undef, 'Y');
my $sr_slice = $slice->seq_region_Slice();
my $regulatory_feature_adaptor = $registry->get_adaptor('human', 'funcgen', 'regulatoryfeature');

my $regulatory_features = $regulatory_feature_adaptor->fetch_all_by_Slice($slice);

foreach my $rf (@$regulatory_features) {
  print STDERR  join(" ", $rf->stable_id, $rf->seq_region_name,  $rf->start, $rf->end), "\n";
  my $motif_features = $rf->get_all_experimentally_verified_MotifFeatures();
  foreach my $mf (@$motif_features) {
#    $mf->transfer($rf->slice);
    print STDERR "    ", join(" ", $mf->stable_id, $mf->seq_region_name,  $mf->start, $mf->end), "\n";  
  }
}

