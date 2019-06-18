use strict;
use warnings;

use FileHandle;

my $dir = '/hps/nobackup2/production/ensembl/anja/cadd_dbnsfp_pipeline_documentation/';

my @headers = ();
my $fh = FileHandle->new("$dir/h", 'r');

while (<$fh>) {
  chomp;
  @headers = split/\t/ if (/^#/);
}
$fh->close;


#$fh = FileHandle->new("$dir/dbnsfp_grch38_3.5_17_54968644_54968646.out", 'r');
$fh = FileHandle->new("$dir/dbnsfp_grch38_3.5_3_193255705_193255707.out", 'r');

my @columns = qw/#chr pos(1-based) ref alt refcodon aaref aaalt REVEL_score MetaLR_score MetaLR_pred MutationAssessor_score_rankscore MutationAssessor_pred/;
while (<$fh>) {
  chomp;
  my @row = split/\t/;
  my %tmp = map {$headers[$_] => $row[$_]} (0..$#headers);
  my @values = ();
  foreach my $column (@columns) {
    push @values, $tmp{$column};
  } 
  print join("\t", @values), "\n";
}
$fh->close;
