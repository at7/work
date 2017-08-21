use strict;
use warnings;

use FileHandle;

my $dumps = {};


my $fh = FileHandle->new("/hps/nobackup/production/ensembl/anja/release_90/sheep/split_dumps/24_1000.txt", 'r');
while (<$fh>) {
  chomp;
  $dumps->{$_} = 1;
}
$fh->close;

$fh = FileHandle->new("/hps/nobackup/production/ensembl/anja/release_90/sheep/dumps/24.txt", 'r');
while (<$fh>) {
  chomp;
  if (!$dumps->{$_}) {
    print STDERR $_, "\n";
  }
}
$fh->close;
