use strict;
use warnings;

use FileHandle;

my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/vep_data/output/grch38/homo_sapiens-chr14_94_offline.out', 'r');

#Uploaded_variation     Location        Allele  Gene    Feature Feature_type    Consequence     cDNA_position   CDS_position    Protein_position        Amino_acids     Codons  Existing_variation      Extra
my $counts = {};
while (<$fh>) {
  chomp;
  next if /^#/;
  my @columns = split/\t/; 
  my $extra = $columns[13];
  foreach (split(';', $extra)) {
    if (/=/) {
      my ($key, $value) = split/=/;
      $counts->{$value}++;
    } else {
      $counts->{$_}++;
    }
  }
}

$fh->close;


$fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/vep_data/output/grch38/homo_sapiens-chr14_94_offline_stats.out', 'w');

foreach my $key (keys %$counts) {
  my $count = $counts->{$key};
  print $fh "$key\t$count\n";
}

$fh->close;
