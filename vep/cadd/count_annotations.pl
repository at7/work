use strict;
use warnings;

use FileHandle;


my $dir = '/hps/nobackup2/production/ensembl/anja/vep_data/output/grch37/';

my $fh = FileHandle->new("$dir/all_chr17_dbnsfp_cadd_no_filter.out", 'r');

my $consequence_count = {};
my $consequence_cadd_count = {};
#Uploaded_variation     Location        Allele  Gene    Feature Feature_type    Consequence     cDNA_position   CDS_position    Protein_position        Amino_acids     Codons  Existing_variation      Extra
my $counts = {};
while (<$fh>) {
  chomp;
  next if /^#/;
  next if /^rs560888646/;
  my @columns = split/\t/;
  my $consequence =  $columns[6];
  $consequence_count->{$consequence}++;
  my $extra = $columns[13];
  foreach (split(';', $extra)) {
    if (/^CADD/) {
      $consequence_cadd_count->{$consequence}++;
    }
  }
}
$fh->close;

foreach my $consequence (sort keys %$consequence_count) {
  my $consequence_count_all = $consequence_count->{$consequence};
  my $consequence_count_cadd = $consequence_cadd_count->{$consequence} || 0;
  print STDERR "$consequence $consequence_count_cadd $consequence_count_all\n";
}

