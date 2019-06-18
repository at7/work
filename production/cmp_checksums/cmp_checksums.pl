use strict;
use warnings;



use FileHandle;


my $sums96 = {};
my $sums97 = {};


my $fh = FileHandle->new('CHECKSUMS_GVF_96', 'r');
while (<$fh>) {
  chomp;
  my ($fst, $snd, $filename) = split /\s+/;
  $sums96->{$filename}->{fst} = $fst;
  $sums96->{$filename}->{snd} = $snd;
}

$fh->close;

$fh = FileHandle->new('CHECKSUMS_GVF_97', 'r');
while (<$fh>) {
  chomp;
  my ($fst, $snd, $filename) = split(/\s+/, $_);
  next unless (defined $sums96->{$filename});
  my $fst96 = $sums96->{$filename}->{fst};
  my $snd96 = $sums96->{$filename}->{snd};
  if (($snd/$snd96 < 0.95) || ($snd/$snd96 > 1.05)) {
    print "$filename $snd96 $snd\n";
  }
}

$fh->close;



