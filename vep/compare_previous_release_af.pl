use strict;
use warnings;

use FileHandle;
use Scalar::Util qw(looks_like_number);



my $ref_data_hash = {};

my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/vep_data/input/grch38/allele_frequencies_92.txt', 'r');

while(<$fh>) {
  chomp;
  my @tmp = split(/\s+/, $_);
  $ref_data_hash->{$tmp[5]} = [map {s/^.+?\://g; $_} @tmp];
}
$fh->close;

$fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/vep_data/output/allele_frequencies_91_92.txt', 'r');

while(<$fh>) {
  next if (/^#/);
  chomp;
  my @data = split("\t", $_);
  my $rs = shift @data;

  if(my $ref_data = $ref_data_hash->{$rs}) {

    # ref_data contains all the input bits too, shift them off
    while(@$ref_data > @data) {
      shift @$ref_data;
    }

    # now compare
    my $mismatches = 0;

    for my $i(0..$#data) {
      next unless looks_like_number($ref_data->[$i]);
      $mismatches++ if !looks_like_number($data[$i]) || sprintf("%.3g", $ref_data->[$i]) != sprintf("%.3g", $data[$i]);
    }

    if($mismatches) {
      print STDERR "ERROR: Mismatched frequencies in $rs (IN vs OUT):\n".join("\t", @$ref_data)."\n".join("\t", @data)."\n";
    }
  }
  else {
    print STDERR "ERROR: no ref data found for $rs\n";
  }
}

$fh->close;

