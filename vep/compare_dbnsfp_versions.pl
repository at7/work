use strict;
use warnings;


use FileHandle;


# count transcripts

my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/dbNSFP/grch37/dbnsfp_3.5_grch37_missense.txt', 'r');

my $transcripts = {};

while (<$fh>) {
  chomp;
  my @values = split/\t/;
  my $extra = $values[13];
  foreach my $pair (split(/;/, $extra)) {
    my ($key, $value) = split(/=/, $pair);
    if ($key eq 'Ensembl_transcriptid') {
      foreach my $transcript_id (split(',', $value)) {
        $transcripts->{$transcript_id} = 1;
      }
    }
  } 
}

$fh->close();

print STDERR scalar keys %$transcripts, "\n";


sub compare_fields {
  my $fields_2_9 = {};
  my $fields_3_5 = {};

  filter_extra_fields('/hps/nobackup2/production/ensembl/anja/dbNSFP/grch37/dbnsfp_2.9_grch37_missense.txt', $fields_2_9);
  filter_extra_fields('/hps/nobackup2/production/ensembl/anja/dbNSFP/grch37/dbnsfp_3.5_grch37_missense.txt', $fields_3_5);

  print STDERR "New in 3.5\n";

  foreach my $key (sort keys %$fields_3_5) {
    if (!$fields_2_9->{$key}) {
      print STDERR $key, "\n";
    }
  }

  print STDERR "Missing in 3.5\n";

  foreach my $key (sort keys %$fields_2_9) {
    if (!$fields_3_5->{$key}) {
      print STDERR $key, "\n";
    }
  }
}

sub filter_extra_fields {
  my $file = shift;
  my $fields = shift;
  my $fh = FileHandle->new($file, 'r');
  #Uploaded_variation     Location        Allele  Gene    Feature Feature_type    Consequence     cDNA_position   CDS_position    Protein_position        Amino_acids     Codons  Existing_variation      Extra
  while (<$fh>) {
    chomp;
    my @values = split/\t/;
    my $extra = $values[13];
    foreach my $pair (split(/;/, $extra)) {
      my ($key, $value) = split(/=/, $pair);
      $fields->{$key} = 1;
    } 
  }
  $fh->close;
}





sub extract_missense {
  my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/dbNSFP/grch37/dbnsfp_3.5_grch37.txt', 'r');
  my $fh_out = FileHandle->new('/hps/nobackup2/production/ensembl/anja/dbNSFP/grch37/dbnsfp_3.5_grch37_missense.txt', 'w');

  my $variants = {};
  #Uploaded_variation     Location        Allele  Gene    Feature Feature_type    Consequence     cDNA_position   CDS_position    Protein_position        Amino_acids     Codons  Existing_variation      Extra
  while (<$fh>) {
    chomp;
    next if /^#/;
    my @values = split/\t/;
    my $variant = $values[0];
    my $allele = $values[2];
    my $consequence = $values[6];
    if ($consequence =~ /missense_variant|stop_lost|stop_gained|start_lost/) {
      if (!$variants->{$variant} || !$variants->{$variant}->{$allele}) {
        print $fh_out $_, "\n";
      } 
      $variants->{$variant}->{$allele} = 1;
    }
  }

  $fh->close;
  $fh_out->close;
}
