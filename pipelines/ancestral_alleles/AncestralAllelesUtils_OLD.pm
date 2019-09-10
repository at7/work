package AncestralAllelesUtils;

use strict;
use warnings;

use base qw(Exporter);


our @EXPORT_OK = qw(assign_ancestral_allele);


sub get_sequence_id_mappings {

  my @sequence_ids = ();
  if ($fasta_db->isa('Bio::DB::HTS::Faidx')) {
    @sequence_ids = $fasta_db->get_all_sequence_ids;
  } elsif ($fasta_db->isa('Bio::DB::Fasta')) {
    @sequence_ids = $fasta_db->get_all_ids;
  } else {
    throw("ERROR: Could'n get sequence ids from ".ref($fasta_db)."\n");
  }

  my %sequence_id_2_chr_number;

  foreach my $sequence_id (@sequence_ids) {
    my @split = split(/:/, $sequence_id);
    $sequence_id_2_chr_number{$split[2]} = $sequence_id;
  }

}

sub assign_ancestral_allele {
  my ($fasta_db, $chrom, $start, $end, $strand) = @_;

  # insertion
  return undef if ($start > $end);
  # allele size limit to 50bp
  return undef if (($end - $start) > 50); 


  # alternative sequences are not represented in the ancestral fasta file 
  return undef if (!($chrom && $start && $end));

  my $ancestral_allele = undef;

  if ($fasta_db->isa('Bio::DB::HTS::Faidx') ) {
    $ancestral_allele = $fasta_db->get_sequence_no_length("$chrom:$start-$end");
  } elsif ($fasta_db->isa('Bio::DB::Fasta')) {
    $ancestral_allele = $fasta_db->seq("$chrom:$start,$end");
  } else {
    throw("ERROR: Don't know how to fetch sequence from a ".ref($fasta_db)."\n");
  }

  return undef unless ($ancestral_allele && $ancestral_allele =~ m/^[ACGTacgt]+$/);
  
  $ancestral_allele = uc $ancestral_allele;

  return $ancestral_allele;

}


