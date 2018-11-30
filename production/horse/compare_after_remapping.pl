use strict;
use warnings;

use FileHandle;
use Data::Dumper;


my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/horse/compare_gts/horse_94', 'r');
my $hash94 = {};

my $found_last = 0;

while (<$fh>) {
  chomp;
  my  ($variation_name, $allele_string, $frequency, $count, $genotype) = split/\s/;
  $hash94->{$variation_name}->{$allele_string}->{$genotype}->{$count} = $frequency;
}

$fh->close;


$fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/horse/compare_gts/horse_95', 'r');

while (<$fh>) {
  chomp;
  my  ($variation_name, $allele_string, $frequency, $count, $genotype) = split/\s/;

  if ($variation_name eq 'rs1142346471') {
    $found_last = 1;
  }

  if (!$found_last) {
    if (!defined $hash94->{$variation_name}) {
      print STDERR "Not in 94 $variation_name\n";
    } elsif (!defined $hash94->{$variation_name}->{$allele_string}) {
      print STDERR "Allele string not in 94 $variation_name $allele_string $frequency $count $genotype\n";
      print STDERR Dumper($hash94->{$variation_name}), "\n";
    }
  }
}

$fh->close;
