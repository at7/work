use strict;
use warnings;

use FileHandle;

use Bio::EnsEMBL::Registry;
use Bio::Tools::CodonTable;

use Data::Dumper;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 92,
);


my $transcript_adaptor = $registry->get_adaptor('human', 'core', 'transcript');
my $slice_adaptor = $registry->get_adaptor('human', 'core', 'slice');
my $codonTable   = Bio::Tools::CodonTable->new();
my $transcript = $transcript_adaptor->fetch_by_stable_id('ENST00000458104.6');
my $strand = $transcript->seq_region_strand;
my $start = $transcript->seq_region_start;
my $end = $transcript->seq_region_end;
my $chrom = $transcript->seq_region_name;
my $slice = $slice_adaptor->fetch_by_region('chromosome', $chrom,  $start, $end, $strand);
my $translation = $transcript->translation;
my $transcript_mapper = $transcript->get_TranscriptMapper();
foreach my $i (1 .. $translation->length) {
  my @pep_coordinates = $transcript_mapper->pep2genomic($i, $i);
  my $triplet = '';
  foreach my $coord (@pep_coordinates) {
    my $coord_start = $coord->start;
    my $coord_end = $coord->end;
    my $new_start = $coord_start - $start + 1;    
    my $new_end   = $coord_end   - $start + 1;    
    my $subseq = $slice->subseq($new_start, $new_end);
    $triplet .= $subseq;
  }

  my $aa = $codonTable->translate($triplet);
  print "$i $triplet $aa\n";    
  my $new_triplets = mutate($triplet);

}

sub mutate {
  my $triplet = shift;

  my @nucleotides = split('', $triplet);
  my $new_triplets;
  foreach my $i (0 .. $#nucleotides) {
    my $mutations = get_mutations($nucleotides[$i]);
    get_mutated_triplets($triplet, $mutations, $i, $new_triplets);
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
    $new_triplets->{$triplet}->{$position}->{$mutation} = $update_triplet;
  }

}


sub get_mutations {
  my $nucleotide = shift;
  my $hash = {
    'A' => ['C', 'G', 'T'], 
    'C' => ['A', 'G', 'T'],
    'G' => ['A', 'C', 'T'],
    'T' => ['A', 'C', 'G'],
  };
  return $hash->{$nucleotide};
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


my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_94/human/dbNSFP/translations_chrom1', 'w');

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




