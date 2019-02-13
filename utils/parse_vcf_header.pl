use strict;
use warnings;


use FileHandle;


my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/gnomad/Exomes/h', 'r');

my $keys = {};

while (<$fh>) {
  chomp;
  next if !/^##INFO/;
  s/##INFO=<//g;
  s/>$//g;
  my @values = split/,/;
  my ($id) = grep {$_ =~ /^ID/} @values;
  my ($desc) = grep {$_ =~ /^Description/} @values;
  $id =~ s/ID=//;
  my @components = split('_', $id);
  print $id, ' ', $desc, "\n";

}

$fh->close;
