use strict;
use warnings;


use FileHandle;

my $variants_fast = {};
my $variants_slow = {};
my $fh = FileHandle->new('variants_fast', 'r');
while (<$fh>) {
  chomp;
  $variants_fast->{$_} = 1;
}
$fh->close();

$fh = FileHandle->new('variants_slow', 'r');
while (<$fh>) {
  chomp;
  $variants_slow->{$_} = 1;
}
$fh->close();

my $count_in_slow = scalar keys %$variants_slow;
my $count_in_fast = scalar keys %$variants_fast;
print 'variants slow ', $count_in_slow, "\n";
print 'variants fast ', $count_in_fast, "\n";
print $count_in_fast - $count_in_slow, "\n";

my $not_in_slow = 0;
foreach my $name (keys %$variants_fast) {
  if (!$variants_slow->{$name}) {
    $not_in_slow++;
  }
}

print 'not in slow ', $not_in_slow, "\n"; 

my $not_in_fast = 0;
foreach my $name (keys %$variants_slow) {
  if (!$variants_fast->{$name}) {
    $not_in_fast++;
  }
}

print 'not in fast ', $not_in_fast, "\n"; 


=begin
my $input = {};

my $fh = FileHandle->new('/tmp/ld0005b30400001e0c56a79c6e22a422e0.in', 'r');

while (<$fh>) {
  chomp;
  my ($chrom, $snp_start, $snp_start, $pop_id, $sample_id, $gt) = split /\s/;
  $input->{"$snp_start $pop_id"} = 1;
}

$fh->close;

print scalar keys %$input, "\n";


$fh = FileHandle->new('tmp_ld_in', 'r');
while (<$fh>) {
  chomp;
  my ($chrom, $snp_start, $snp_start, $pop_id, $sample_id, $gt) = split /\s/;
  unless ($input->{"$snp_start $pop_id"}) {
    print "$_\n";
  }
}
$fh->close();
=end
=cut
