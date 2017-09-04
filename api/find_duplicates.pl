use strict;
use warnings;


use FileHandle;  

my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/tests_dumps/mouse/mus_musculus_1e7.gvf', 'r');

my $hash = {};

while (<$fh>) {
  chomp;
  next if /^#/;
  my $gvf_line = get_gvf_line($_);
  my @dbxref = split(':', $gvf_line->{Dbxref}, 2);
  my ($variation_id, $db) = ($dbxref[1], $dbxref[0]);
  if ($hash->{$variation_id}) {
#    print STDERR "duplicated $variation_id\n";
  }
  $hash->{$variation_id} = 1;
}

$fh->close;

my $fh2 = FileHandle->new('/hps/nobackup/production/ensembl/anja/tests_dumps/mouse/mus_musculus_1e6.gvf', 'r');
while (<$fh2>) {
  chomp;
  next if /^#/;
  my $gvf_line = get_gvf_line($_);
  my @dbxref = split(':', $gvf_line->{Dbxref}, 2);
  my ($variation_id, $db) = ($dbxref[1], $dbxref[0]);
  if (!$hash->{$variation_id}) {
#    print STDERR "missing $variation_id\n";
  }
}
$fh2->close;





sub get_gvf_line {
  my $line = shift;
  my $gvf_line = {};
  my ($seq_id, $source, $type, $start, $end, $score, $strand, $phase, $attrib) = split(/\t/, $line);
  $gvf_line->{seq_id} = $seq_id;
  $gvf_line->{source} = $source;
  $gvf_line->{type} = $type;
  $gvf_line->{start} = $start;
  $gvf_line->{end} = $end;
  $gvf_line->{strand} = $strand;

  foreach my $pair (split(';', $attrib)) {
    my ($key, $value) = split('=', $pair);
    if ($key && $value) {
      $gvf_line->{$key} = $value;
    }
  }
  return $gvf_line;
}

