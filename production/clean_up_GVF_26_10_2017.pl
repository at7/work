use strict;
use warnings;

use FileHandle;
use Compress::Zlib;

my $gvf_file  = '/hps/nobackup/production/ensembl/anja/release_90/dumps_90/gvf/homo_sapiens/Homo_sapiens.gvf';
#my $fh_in = gzopen($gvf_file, "rb") or die "Error reading $gvf_file: $gzerrno\n";
my $fh_in = FileHandle->new($gvf_file, 'r');

my $fh_out = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_90/dumps_90/gvf/homo_sapiens/Homo_sapiens_line_break.gvf', 'w');

my $tmp_line = '';
my $last_line = '';
my $count = 0;
while (<$fh_in>) {
  chomp;
  if (/^#/) {
    print $fh_out $_, "\n";
  } else { 
    if (/^;/) {
      if ($count == 1) {
        print $fh_out $last_line, $_, "\n";
        $count = 0;
      } else {
        print STDERR "$_ $last_line $count\n";
      }
    } else {
      if ($count == 0 ) {
        $last_line = $_;
        $count++;
      } else {
        print $fh_out $last_line, "\n";
        $last_line = $_;
        $count = 1;
      }
    }
  }
}

$fh_in->close();

=begin
while ($fh_in->gzreadline($_) > 0) {
  if (/^#/) {
    print $fh_out $_, "\n";
  } else {
    my $line = $_;
    my $gvf_line = get_gvf_line($line);
    delete $gvf_line->{attributes}->{variation_id};
    delete $gvf_line->{attributes}->{allele_string};
    $line = join("\t", map {$gvf_line->{$_}} (
    'seq_id',
    'source',
    'type',
    'start',
    'end',
    'score',
    'strand',
    'phase'));
    my $attributes = join(";", map{"$_=$gvf_line->{attributes}->{$_}"} keys %{$gvf_line->{attributes}});
    print $fh_out $line, "\t", $attributes, "\n";
  }
}
=end
=cut
#$fh_in->gzclose(); 
$fh_out->close();

sub get_gvf_line {
  my $line = shift;
  my $gvf_line = {};
  my @header_names = qw/seq_id source type start end score strand phase/;
  my @header_values = split(/\t/, $line);
  my $attrib = pop @header_values;

  for my $i (0 .. $#header_names) {
    $gvf_line->{$header_names[$i]} = $header_values[$i];
  }

  my @attributes = split(';', $attrib);
  foreach my $attribute (@attributes) {
    my ($key, $value) = split('=', $attribute);
    if ($value) {
      $gvf_line->{attributes}->{$key} = $value;
    }
  }
  return $gvf_line;
}

