#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);
use FileHandle;
use Bio::EnsEMBL::Funcgen::DBSQL::DBAdaptor;
use Data::Dumper;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 94,
);

my $slice_adaptor = $registry->get_adaptor('human', 'core', 'slice');
my $slice = $slice_adaptor->fetch_by_region('chromosome', '13');

my $regulatory_feature_adaptor = $registry->get_adaptor('human', 'funcgen', 'regulatoryfeature');

my $regulatory_features = $regulatory_feature_adaptor->fetch_all_by_Slice($slice);

my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/human/funcgen/motif_feature_chrom13', 'w');

foreach (@$regulatory_features) {
  my $motif_features = $_->fetch_all_MotifFeatures_with_matching_Peak();
  foreach my $mf (@$motif_features) {
    print $fh $mf->stable_id, "\n";
  }
}

$fh->close;
