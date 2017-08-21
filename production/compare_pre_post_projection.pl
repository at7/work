use strict;
use warnings;

use FileHandle;

my $files = {
  pre_projection => 'variation_feature_topmed_38',
  post_projection => 'variation_feature_post_projection_90_37_2',
};

my $counts = {};

foreach my $key (keys %$files) {
  my $file = $files->{$key};
  my $fh = FileHandle->new($file, 'r');
  while (<$fh>) {
    chomp;
    next if /^name/;
    my ($chrom, $count) = split/\s/;
    $counts->{$chrom}->{$key} = $count;
  }
  $fh->close;
}

foreach my $chrom (keys %$counts) {
  my $pre_count = $counts->{$chrom}->{pre_projection};
  my $post_count = $counts->{$chrom}->{post_projection};
  my $ratio = $post_count/$pre_count;
  print STDERR "$chrom $ratio\n";

}
