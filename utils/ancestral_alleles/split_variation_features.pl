use strict;
use warnings;


use FileHandle;


my $dir = '/hps/nobackup2/production/ensembl/anja/release_96/human/ancestral_alleles/input/';

my $vf_file = '/hps/nobackup2/production/ensembl/anja/release_96/human/ancestral_alleles/variation_features_96.txt';


my $count = 10_000_000;


my $file_count = 1;
my $i = 0;
my $fh = FileHandle->new($vf_file, 'r');
my $fh_write = FileHandle->new("$dir/$file_count.txt", 'w');
while (<$fh>) {
  if ($i < $count) {
    print $fh_write $_;
    $i++;
  } else {
    $fh_write->close;
    $file_count++;
    $fh_write = FileHandle->new("$dir/$file_count.txt", 'w');
    print $fh_write $_;
    $i = 1;
  }
}

$fh_write->close;
$fh->close;


