use strict;
use warnings;


use FileHandle;
##Uploaded_variation     Location        Allele  Gene    Feature Feature_type    Consequence     cDNA_position   CDS_position    Protein_position        Amino_acids     Codons  Existing_variation      Extra
#rs185559716     13:114344377    T       ENSG00000260615 ENST00000568955 Transcript      upstream_gene_variant   -       -       -       -       -       rs185559716    IMPACT=MODIFIER;DISTANCE=1790;STRAND=1;AF=0.0387;AFR_AF=0.0045;AMR_AF=0.0533;EAS_AF=0.001;EUR_AF=0.1213;SAS_AF=0.0286;MAX_AF=0.1213;MAX_AF_POPS=EUR

my $from = 16000198;
my $to = 16000198;

while ($to < 114353903) {
  $from = $to + 1;
  $to += 5717695;
  my $fh_release_91 = FileHandle->new('/hps/nobackup/production/ensembl/anja/vep_data/output/homo_sapiens_chrom13_cache_frequencies_91_38.txt', 'r');
  my $fh_release_92 = FileHandle->new('/gpfs/nobackup/ensembl/anja/vep_data/output/homo_sapiens_chrom13_cache_frequencies_92_38.txt', 'r');
  my $hash = {};

  while (<$fh_release_91>) {
    chomp;
    next if /^#/;
    my @values = split/\t/;
    my $var = $values[0];
    my $allele = $values[2];
    my $gene = $values[3];
    my $transcript = $values[4]; 
    my $consequence = $values[6];
    my $existing = $values[12];
    my $extra = $values[13];
    $values[1] =~ /(\d+):(\d+)(\-\d+)?/;
    if ($2 >= $from && $2 < $to) {
      $hash->{$var}->{$gene}->{$transcript}->{$allele}->{consequence} = $consequence;  
      foreach (split(';', $extra)) {
        my ($extra_key, $extra_value) = split/=/;
        $hash->{$var}->{$gene}->{$transcript}->{$allele}->{$extra_key} = $extra_value;
      }
    }
  }

  while (<$fh_release_92>) {
    chomp;
    next if /^#/;
    my @values = split/\t/;
    my $var = $values[0];
    my $allele = $values[2];
    my $gene = $values[3];
    my $transcript = $values[4]; 
    my $consequence = $values[6];
    my $existing = $values[12];
    my $extra = $values[13];
    $values[1] =~ /(\d+):(\d+)(\-\d+)?/;
    if ($2 >= $from && $2 < $to) {
      my $consequence_last_release = $hash->{$var}->{$gene}->{$transcript}->{$allele}->{consequence} || 'NA';  
      if ($consequence ne $consequence_last_release) {
        print STDERR "Difference for $var $gene $transcript $allele Last release $consequence_last_release VS This release $consequence\n";
      }
      foreach (split(';', $extra)) {
        my ($extra_key, $extra_value) = split/=/;
        my $extra_value_last_release = $hash->{$var}->{$gene}->{$transcript}->{$allele}->{$extra_key} || 'NA';
        if ($extra_value_last_release ne $extra_value) {
          print STDERR "Difference for $var $gene $transcript $allele $extra_key Last release $extra_value_last_release VS This release $extra_value\n";
        }
      }
    }
  }
}


