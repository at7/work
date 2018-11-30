use strict;
use warnings;


use FileHandle;


my $stats94 = {};
my $stats95 = {};

my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/vep_data/output/grch38/homo_sapiens-chr14_94_offline_stats.out', 'r');
while (<$fh>) {
  chomp;
  my ($key, $value) = split/\t/;
  $stats94->{$key} = $value;
}
$fh->close;
$fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/vep_data/output/grch38/homo_sapiens-chr14_offline_stats.out', 'r');
while (<$fh>) {
  chomp;
  my ($key, $value) = split/\t/;
  $stats95->{$key} = $value;
}
$fh->close;

foreach my $key (keys %$stats95) {
  if (!defined $stats94->{$key}) {
    print STDERR "Not in 94 $key\n";
  } elsif ($stats94->{$key} ne $stats95->{$key}) {
    print STDERR "Different values for $key: ", $stats94->{$key}, ' ', $stats95->{$key}, "\n";
  }
}
