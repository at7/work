package AncestralAllelesUtils;

use strict;
use warnings;
use Bio::EnsEMBL::Utils::Argument qw(rearrange);

sub new {
  my $caller = shift;
  my $class = ref($caller) || $caller;
  my ($fasta_db) = rearrange([qw(FASTA_DB)], @_);
  my $self = bless {
    'fasta_db' => $fasta_db,
  }, $class;

  return $self;
}

sub fasta_db {
  my $self = shift;
  return $self->{'fasta_db'}; 
}

sub sequence_id_mappings {
  my $self = shift;
  if (!defined $self->{'sequence_id_mappings'}) {
    my $fasta_db = $self->fasta_db;
    my @sequence_ids = ();
    if ($fasta_db->isa('Bio::DB::HTS::Faidx')) {
      @sequence_ids = $fasta_db->get_all_sequence_ids;
    } elsif ($fasta_db->isa('Bio::DB::Fasta')) {
      @sequence_ids = $fasta_db->get_all_ids;
    } else {
      throw("ERROR: Could'n get sequence ids from ".ref($fasta_db)."\n");
    }

    my $sequence_id_2_chr_number;

    foreach my $sequence_id (@sequence_ids) {
      my @split = split(/:/, $sequence_id);
      $sequence_id_2_chr_number->{$split[2]} = $sequence_id;
    }
    $self->{'sequence_id_mappings'} = $sequence_id_2_chr_number;
  }
  return $self->{sequence_id_mappings};
}

sub get_fasta_sequence_id {
  my $self = shift;
  my $chrom = shift;
  my $sequence_id_mappings = $self->sequence_id_mappings;
  return $sequence_id_mappings->{$chrom};  
}

sub assign_ancestral_allele {
  my ($self, $chrom, $start, $end, $strand) = @_;

  # insertion
  return undef if ($start > $end);
  # allele size limit to 50bp
  return undef if (($end - $start) > 50); 

  # alternative sequences are not represented in the ancestral fasta file 
  $chrom = $self->get_fasta_sequence_id($chrom);
  return undef if (!($chrom && $start && $end));

  my $ancestral_allele = undef;

  my $fasta_db = $self->fasta_db;
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

1;
