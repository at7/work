use strict;
use warnings;

use FileHandle;

#ftp://ftp.ensembl.org/pub/release-92/variation/gvf/homo_sapiens/1000GENOMES-phase_3.gvf.gz

#my $dir = '/hps/nobackup2/production/ensembl/anja/release_93/human/dumps/gvf/';
#my $dir = '/hps/nobackup2/production/ensembl/anja/release_94/human/dumps/gvf/';

#my $dir = '/hps/nobackup2/production/ensembl/anja/release_94/human/grch37/dumps/gvf/homo_sapiens/';
#my $dir = '/hps/nobackup2/production/ensembl/anja/release_95/human/grch37/dumps/gvf/homo_sapiens/';


my $dir = '/hps/nobackup2/production/ensembl/anja/release_97/human/dumps/population_dumps/gvf/homo_sapiens/';

my $fh_out = FileHandle->new("$dir/1000GENOMES-phase_3.gvf", 'w'); 

my $fh_header = FileHandle->new("$dir/gvf_header", 'r');
while (<$fh_header>) {
  chomp;
  print $fh_out "$_\n";
}
$fh_header->close;

my $id = 1;

for my $i (1..22,'X', 'Y') {

  my $fh_in = FileHandle->new("$dir/1000GENOMES-phase_3_chrom$i.gvf", 'r');

  while (<$fh_in>) {
    chomp;
    next if (/^#/);
    my $line = $_;
    my $gvf_line = get_gvf_line($line);
    delete $gvf_line->{attributes}->{variation_id};
    delete $gvf_line->{attributes}->{allele_string};
    $gvf_line->{attributes}->{ID} = $id;
    $id++;

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

  $fh_in->close;
}

$fh_out->close;

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
