use strict;
use warnings;


use FileHandle;

my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/human/funcgen/regulatory_feature_split_slice', 'r');

my $ids = {};

while (<$fh>) {
  chomp;
  $ids->{$_} = 1;
}

$fh->close;

print STDERR scalar keys %$ids, "\n";


