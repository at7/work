use strict;
use warnings;

use FileHandle;


my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/1000Genomes_chr10_insertions_old_cache.out', 'r');

my $counts = {};

while (<$fh>) {
  chomp;
  next if /^#/;
  my @columns = split/\t/;
  my @info_fields = split(';', $columns[13]);
  foreach my $info_field (@info_fields) {
    my ($key, $value) = split('=', $info_field);
    $counts->{$key}++;
  }
}

$fh->close();

foreach my $value (sort {$counts->{$a} <=> $counts->{$b} } keys %$counts) {
  print STDERR $value, ' ', $counts->{$value}, "\n";
}

