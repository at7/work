use strict;
use warnings;

use FileHandle;

my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/goat/MOCH/cmp_gts_chrom1_old_assembly', 'r');

my $map = {};
while (<$fh>) {
  chomp;
  my @values = split/\t/;
  $map->{$values[0]} = 1;
}
$fh->close;


$fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/goat/ITCH/cmp_gts_chrom1_old_assembly', 'r');
while (<$fh>) {
  chomp;
  my @values = split/\t/;
  if (!$map->{$values[0]}) {
    print STDERR $values[0], "\n";
  }
}
$fh->close



