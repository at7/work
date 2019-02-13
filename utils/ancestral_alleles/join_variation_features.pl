use strict;
use warnings;

use FileHandle;

my $dir = '/hps/nobackup2/production/ensembl/anja/release_96/human/ancestral_alleles/input/';
my $vf_aa_file = '/hps/nobackup2/production/ensembl/anja/release_96/human/ancestral_alleles/variation_features_96_AA.txt';

my $fh = FileHandle->new($vf_aa_file, 'w');

for my $i (1..70) {
  my $fh_txt = FileHandle->new("$dir/$i.txt", 'r');
  while (<$fh_txt>) {
    print $fh $_;
  }
  $fh_txt->close;

}

$fh->close;

