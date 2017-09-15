use strict;
use warnings;

use FileHandle;

my $fh = FileHandle->new('ld_vcf_incremental.out', 'r');
my $hash = {};
while (<$fh>) {
  chomp;
#1 1 26548984  rs34246779  26563636  rs72844462  1.000000  1.000000  182
  my @values = split/\s/;
  my $variant1 = $values[3];
  my $variant2 = $values[5];
  my $r2 = $values[6];
  my $D = $values[7];
  $hash->{$variant1}->{$variant2}->{r2} = $r2;
  $hash->{$variant1}->{$variant2}->{D} = $D;
  $hash->{$variant2}->{$variant1}->{r2} = $r2;
  $hash->{$variant2}->{$variant1}->{D} = $D;
}
$fh->close;

my $plink_hash = {};
$fh = FileHandle->new('/Users/anja/Documents/src/plink_mac/plink.ld', 'r');
while (<$fh>) {
  chomp;
  $_ =~ s/^\s+//;
  next if (/^CHR_A/);
  my @values = split/\s+/;
#6     26548984    rs34246779      6     26612642    rs11967852     0.409091            1
  my $variant1 = $values[2]; 
  my $variant2 = $values[5];
  my $r = $values[6]; 
  my $D = $values[7];
  $plink_hash->{$variant1}->{$variant2}->{r2} = $r;
  $plink_hash->{$variant1}->{$variant2}->{D} = $D;
  $plink_hash->{$variant2}->{$variant1}->{r2} = $r;
  $plink_hash->{$variant2}->{$variant1}->{D} = $D;
}
$fh->close;

$fh = FileHandle->new('ld_vcf.out', 'r');

my $printed = {};

while (<$fh>) {
  chomp;
  my @values = split/\s/;
  my $variant1 = $values[3];
  my $variant2 = $values[5];
  my $r2 = $values[6];
  my $D = $values[7];
  if ($hash->{$variant1}) {
    if ($hash->{$variant1}->{$variant2}) {
      my $r_incr = $hash->{$variant1}->{$variant2}->{r2};
      my $D_incr = $hash->{$variant1}->{$variant2}->{D};
      if (($r_incr != $r2) || ($D_incr != $D)) {
        my $plink_r = $plink_hash->{$variant1}->{$variant2}->{r2} || 'NA';
        my $plink_D = $plink_hash->{$variant1}->{$variant2}->{D} || 'NA';
        if ($plink_r) {
          my $key1 = "$variant1$variant2";
          my $key2 = "$variant2$variant1";
          if (!$printed->{$key1} && !$printed->{$key2}) {
            print "$variant1 $variant2 R2: $plink_r $r_incr $r2 D': $plink_D $D_incr $D\n";
            $printed->{$key1} = 1;
            $printed->{$key2} = 1;
          }
        }
#rs71546548 rs67971217 0.135962 0.064793 0.629386 0.999718
      }
    }
  }
}

$fh->close;

#$fh = FileHandle->new('LDMatrixSNPs', 'w');
#foreach my $variant (keys %$hash) {
#  print $fh "$variant\n";
#}
#$fh->close;

