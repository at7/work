use warnings;

use FileHandle;
use Compress::Zlib;

my $i = $ENV{'LSB_JOBINDEX'};

if ($i == 23) {
  $i = 'X';
}
if ($i == 24) {
  $i = 'Y';
}

my $from_dir = '/hps/nobackup2/production/ensembl/anja/release_94/human/population_dumps/gvf/with_tmp_keys/';
my $to_dir = '/hps/nobackup2/production/ensembl/anja/release_94/human/population_dumps/gvf/homo_sapiens/';

my $fh_out = FileHandle->new("$to_dir/homo_sapiens-chr$i.gvf", 'w'); 

my $gvf_file = "$from_dir/homo_sapiens-chr$i.gvf.gz";
my $fh_in = gzopen($gvf_file, "rb") or die "Error reading $gvf_file: $gzerrno\n";
while ($fh_in->gzreadline($_) > 0) {
  chomp;
  if (/^#/) {
    print $fh_out "$_\n";
    next;
  }
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

$fh_in->gzclose();

$fh_out->close;

`gzip $to_dir/homo_sapiens-chr$i.gvf`;


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
