use strict;
use warnings;

use Bio::DB::HTS::Tabix;
use Bio::Tools::CodonTable;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Sequence qw(reverse_comp);

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_94/human/ensembl.registry');
my $vdba = $registry->get_DBAdaptor('human', 'variation');
my $cdba = $registry->get_DBAdaptor('human', 'core');
my $codonTable = Bio::Tools::CodonTable->new();
my $REVEL_CUTOFF = 0.5;
my $predictions = {
    dbnsfp_meta_lr => {
      T => 'tolerated',
      D => 'damaging',
    },
    dbnsfp_mutation_assessor => {
      H => 'high',
      M => 'medium',
      L => 'low',
      N => 'neutral',
    }
  };
my $dbnsfp_file = '/nfs/production/panda/ensembl/variation/data/dbNSFP/3.5a/dbNSFP3.5a.txt.gz';

my $obj = Bio::DB::HTS::Tabix->new(filename => $dbnsfp_file);

my $headers;
open HEAD, "tabix -fh $dbnsfp_file 1:1-1 2>&1 | ";
while(<HEAD>) {
  next unless /^\#/;
  chomp;
  $headers = [split];
}
close HEAD;

#my $translation_stable_id = 'ENSP00000411532';
#my $translation_stable_id = 'ENSP00000268459';
#my $translation_stable_id = 'ENSP00000378422';
my $translation_stable_id = 'ENSP00000326135';

my $translation_adaptor = $cdba->get_TranslationAdaptor;
my $translation = $translation_adaptor->fetch_by_stable_id($translation_stable_id);

my $translation_seq = $translation->seq;
my $transcript_stable_id = $translation->transcript->stable_id;
my $transcript = $translation->transcript;
my $reverse = $transcript->strand < 0;

my $pfpma = $vdba->get_ProteinFunctionPredictionMatrixAdaptor or die "Failed to get matrix adaptor";
my @amino_acids = ();
my @all_triplets = @{get_triplets($translation_stable_id)};
foreach my $entry (@all_triplets) {
  my $aa = $entry->{aa};
  push @amino_acids, $aa;
  next if $aa eq 'X';
  my @coords = @{$entry->{coords}};
  my $chrom = $entry->{chrom};
  my $triplet_seq = $entry->{triplet_seq};
  my $i = $entry->{aa_position};
  my $new_triplets = $entry->{new_triplets};
  foreach my $coord (@coords) {
    my $triplet_start = $coord->[0];
    my $triplet_end = $coord->[1];
    
    my $iter = $obj->query("$chrom:$triplet_start-$triplet_end");
    while (my $line = $iter->next) {
      $line =~ s/\r$//g;
      my @split = split /\t/, $line;
      my %data = map {$headers->[$_] => $split[$_]} (0..(scalar @{$headers} - 1));
      my $chr = $data{'#chr'};
      my $revel_raw = $data{'REVEL_score'};
      my $revel_rank = $data{'REVEL_rankscore'};
      my $metaLR_score = $data{'MetaLR_score'};
      my $metaLR_pred = $data{'MetaLR_pred'};
      my $mutation_assessor_rankscore = $data{'MutationAssessor_score_rankscore'};
      my $mutation_assessor_pred = $data{'MutationAssessor_pred'};
      my $pos = $data{'pos(1-based)'};
      print STDERR "Pos $pos $triplet_start $triplet_end\n";
      my $nucleotide_position = ($reverse) ? $triplet_end - $pos : $pos - $triplet_start;
      my $ref = $data{'ref'};
      my $refcodon = $data{'refcodon'};
      my $alt = $data{'alt'};
      next if ($alt eq $ref);
      my $aaalt = $data{'aaalt'};
      my $aaref = $data{'aaref'};

      my $mutated_triplet =  $new_triplets->{$triplet_seq}->{$nucleotide_position}->{$alt};
      my $mutated_aa = $codonTable->translate($mutated_triplet);
      next if ($aaalt ne $mutated_aa);
      print STDERR "$chrom:$triplet_start-$triplet_end $triplet_seq mutated triplet $mutated_triplet $pos $nucleotide_position Ref $ref Alt $alt aa_ref $aaref aa_alt $aaalt mutated_aa $mutated_aa\n";
      if ($revel_raw ne '.') {
        my $prediction = ($revel_raw >= $REVEL_CUTOFF) ? 'likely disease causing' : 'likely benign';
        my $low_quality = 0;
        print STDERR join(" ", ('revel', $i, $mutated_aa, $prediction, $revel_raw)), "\n";
      }
      if ($metaLR_score ne '.') {
        my $prediction = $predictions->{dbnsfp_meta_lr}->{$metaLR_pred};
        my $low_quality = 0;
        print STDERR join(" ", ('meta_lr', $i, $mutated_aa, $prediction, $metaLR_score)), "\n";
      }
      if ($mutation_assessor_rankscore ne '.') {
        my $prediction = $predictions->{dbnsfp_mutation_assessor}->{$mutation_assessor_pred};
        my $low_quality = 0;
        print STDERR join(" ", ('mutation_assessor', $i, $mutated_aa, $prediction, $mutation_assessor_rankscore)), "\n";
      }
    }
  }
}


sub get_triplets {
  my $translation_stable_id = shift;
  my $translation_adaptor = $cdba->get_TranslationAdaptor or die "Failed to get translation adaptor";
  my $translation = $translation_adaptor->fetch_by_stable_id($translation_stable_id);
  my $slice_adaptor = $cdba->get_SliceAdaptor or die "Failed to get slice adaptor";

  my $transcript = $translation->transcript;
  my $chrom = $transcript->seq_region_name;
  my $start = $transcript->seq_region_start;
  my $end = $transcript->seq_region_end;
  my $strand = $transcript->seq_region_strand;
  print STDERR "$chrom $start $end\n";
  my $slice = $slice_adaptor->fetch_by_region('toplevel', $chrom,  $start, $end);
  my $transcript_mapper = $transcript->get_TranscriptMapper();

  my $codonTable = Bio::Tools::CodonTable->new();
  my @all_triplets = ();
  print STDERR $translation->seq, "\n";
  foreach my $i (1 .. $translation->length) {
    my @pep_coordinates = $transcript_mapper->pep2genomic($i, $i);
    my $triplet = '';
    my @coords = ();
    foreach my $coord (@pep_coordinates) {
      my $coord_start = $coord->start;
      my $coord_end = $coord->end;
      next if ($coord_start <= 0);
      my $new_start = $coord_start - $start + 1;
      my $new_end   = $coord_end   - $start + 1;
      print STDERR "new_start $new_start new_end $new_end $strand\n";
      my $subseq = $slice->subseq($new_start, $new_end, $strand);
      print STDERR "subseq $subseq\n";
      $triplet .= $subseq;
      push @coords, [$coord_start, $coord_end];
    }
    my $entry = {
      coords => \@coords,
      aa_position => $i,
      chrom => $chrom,
      triplet_seq => $triplet,
    };
    my $aa = $codonTable->translate($triplet);
    print STDERR "$i $triplet $aa\n";
    foreach my $c (@coords) {
      print STDERR $c->[0], ' ', $c->[1], "\n";
    }

    if (!$aa) {
      $entry->{aa} = 'X';
    } else {
      $entry->{aa} = $aa;
      my $reverse = ($strand < 0);
      my $new_triplets = mutate($triplet, $reverse);
      $entry->{new_triplets} = $new_triplets;
    }
    push @all_triplets, $entry;
  }
  return \@all_triplets;
}

sub mutate {
  my $triplet = shift;
  my @nucleotides = split('', $triplet);
  my $reverse = shift;
  my $new_triplets;
  foreach my $i (0 .. $#nucleotides) {
    my $mutations = ['A', 'G', 'C', 'T'];
    $new_triplets = get_mutated_triplets($triplet, $mutations, $i, $new_triplets, $reverse);
  }
  return $new_triplets;
}

sub get_mutated_triplets {
  my $triplet = shift;
  my $mutations = shift;
  my $position = shift;
  my $new_triplets = shift;
  my $reverse = shift;
  foreach my $mutation (@$mutations) {
    my $update_triplet = $triplet;
    if ($reverse) {
      my $reverse_mutation = $mutation;
      reverse_comp(\$reverse_mutation);
      print STDERR "REV $mutation $reverse_mutation\n";
      substr($update_triplet, $position, 1, $reverse_mutation);
    } else { 
      substr($update_triplet, $position, 1, $mutation);
    }
    $new_triplets->{$triplet}->{$position}->{$mutation} = $update_triplet;
  }
  return $new_triplets;
}

