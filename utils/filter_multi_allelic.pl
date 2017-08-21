use strict;
use warnings;

use FileHandle;

my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/1000G_phase3_frequencies_08_05_2017/19.txt', 'r');


while (<$fh>) {
  chomp;
  my @values = split/\t/;
  my $allele_string = $values[2];
  my @alleles = split('/', $allele_string);
  if (scalar @alleles > 2) {
    print STDERR $_, "\n";
  }

}

$fh->close();
