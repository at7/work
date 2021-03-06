use strict;
use warnings;

use FileHandle;

use Bio::EnsEMBL::Registry;
use Bio::Tools::CodonTable;
use Bio::DB::HTS::Tabix;

use Data::Dumper;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 92,
);

my $file = 'dbNSFP3.5a.txt.gz';

my $headers;
open HEAD, "tabix -fh $file 1:1-1 2>&1 | ";
while(<HEAD>) {
  next unless /^\#/;
  chomp;
  $headers = [split];
}
close HEAD;


my $obj = Bio::DB::HTS::Tabix->new(filename => $file);

my $transcript_adaptor = $registry->get_adaptor('human', 'core', 'transcript');
my $slice_adaptor = $registry->get_adaptor('human', 'core', 'slice');
my $codonTable   = Bio::Tools::CodonTable->new();
my $transcript = $transcript_adaptor->fetch_by_stable_id('ENST00000574821');
my $chrom = $transcript->seq_region_name;

my $strand = $transcript->seq_region_strand;
my $start = $transcript->seq_region_start;
my $end = $transcript->seq_region_end;

my $slice = $slice_adaptor->fetch_by_region('chromosome', $chrom,  $start, $end);
my $translation = $transcript->translation;
my $transcript_mapper = $transcript->get_TranscriptMapper();
my @amino_acids = split('', $translation->seq);
my @indices = (1 .. $translation->length );
print $translation->seq, "\n";
foreach my $i (@indices) {
  my @pep_coordinates = $transcript_mapper->pep2genomic($i, $i);
  print Dumper(\@pep_coordinates), "\n";
  my $triplet = ''; 
  my @coords = ();
  foreach my $coord (@pep_coordinates) {
    my $coord_start = $coord->start;
    my $coord_end = $coord->end;
    print "$coord_start $coord_end\n";
    next if ($coord_start <= 0);
    my $new_start = $coord_start - $start + 1;    
    my $new_end   = $coord_end   - $start + 1;    
    my $subseq = $slice->subseq($new_start, $new_end, $strand);
    $triplet .= $subseq;
    print "$coord_start $coord_end $new_start $new_end $triplet\n";
    push @coords, [$coord_start, $coord_end];
  }
  my $aa = $codonTable->translate($triplet);
  print "AA $aa\n";

#  next unless($aa);
  my $new_triplets = mutate($triplet);

  foreach my $coord (@coords) {
    my $triplet_start = $coord->[0];
    my $triplet_end = $coord->[1];
    print "query $triplet_start $triplet_end\n";
    my $iter = $obj->query("$chrom:$triplet_start-$triplet_end");
    while (my $line = $iter->next) {
     $line =~ s/\r$//g;
      my @split = split /\t/, $line;
      # parse data into hash of col names and values
      my %data = map {$headers->[$_] => $split[$_]} (0..(scalar @{$headers} - 1));
      my $chr = $data{'#chr'};
      my $cadd_raw = $data{'CADD_raw'}; 
      my $cadd_rank = $data{'CADD_raw_rankscore'}; 
      my $cadd_phred = $data{'CADD_phred'}; 
      my $revel_raw = $data{'REVEL_score'}; 
      my $revel_rank = $data{'REVEL_rankscore'}; 
      my $metaSVM_score = $data{'MetaSVM_score'};     
      my $metaSVM_pred = $data{'MetaSVM_pred'};     
      my $mutation_assessor_score = $data{'MutationAssessor_score'};
      my $mutation_assessor_pred = $data{'MutationAssessor_pred'};
      my $pos = $data{'pos(1-based)'};
      my $nucleotide_position = $pos - $triplet_start;
#      print "$pos $triplet_start $nucleotide_position\n";
      my $ref = $data{'ref'};
      my $refcodon = $data{'refcodon'};
      my $alt = $data{'alt'};
      next if ($alt eq $ref);
      my $aaalt = $data{'aaalt'};
      my $aaref = $data{'aaref'};
  #    print "$triplet $nucleotide_position $alt\n";
      my $mutated_triplet =  $new_triplets->{$triplet}->{$nucleotide_position}->{$alt};
  #    print "$triplet $nucleotide_position $alt $mutated_triplet\n";
      my $mutated_aa = $codonTable->translate($mutated_triplet);
      print "$i $aa $pos $ref $alt $aaref-$aa $refcodon-$triplet $mutated_triplet $aaalt-$mutated_aa $cadd_raw $cadd_rank $cadd_phred $revel_raw $revel_rank $metaSVM_score $metaSVM_pred $mutation_assessor_score $mutation_assessor_pred\n";    
    }
  }

}

sub mutate {
  my $triplet = shift;

  my @nucleotides = split('', $triplet);
  my $new_triplets;
  foreach my $i (0 .. $#nucleotides) {
    my $mutations = get_mutations($nucleotides[$i]);
    $new_triplets = get_mutated_triplets($triplet, $mutations, $i, $new_triplets);
  }
  return $new_triplets;
}

sub get_mutated_triplets {
  my $triplet = shift;
  my $mutations = shift;
  my $position = shift;
  my $new_triplets = shift;
  
  foreach my $mutation (@$mutations) {
    my $update_triplet = $triplet;
    substr($update_triplet, $position, 1, $mutation); 
#    print "$triplet $position $mutation $update_triplet\n";
    $new_triplets->{$triplet}->{$position}->{$mutation} = $update_triplet;
  }
  return $new_triplets;
}

sub get_mutations {
  my $nucleotide = shift;
  my $hash = {
    'A' => ['C', 'G', 'T'], 
    'C' => ['A', 'G', 'T'],
    'G' => ['A', 'C', 'T'],
    'T' => ['A', 'C', 'G'],
  };
  return ['A', 'C', 'G', 'T'];
#  return $hash->{$nucleotide};
}


#my $transcript_mapper = $transcript->get_TranscriptMapper();
#my @pep_coordinates = $transcript_mapper->genomic2pep($start, $end, $strand);

#foreach my $pep_coord (@pep_coordinates) {
#  print Dumper($pep_coord), "\n";  
#}


if (0) {
my $slice_adaptor = $registry->get_adaptor('human', 'core', 'slice');

my $slice = $slice_adaptor->fetch_by_region('chromosome', 1);
my $chr = 1;
my $start = $slice->start;
my $end = $slice->end;    

my @transcripts = ();


my $fh = FileHandle->new('translations_chrom1', 'w');

for my $gene (@{ $slice->get_all_Genes(undef, undef, 1) }) {
  for my $transcript (@{$gene->get_all_Transcripts}) {
    my $translation = $transcript->translation;
    if ($translation) {
      print $fh $translation->stable_id, "\n";
    }
  }
}
$fh->close;
}




