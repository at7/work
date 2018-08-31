use strict;
use warnings;


use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Slice qw(split_Slices);

my $registry = 'Bio::EnsEMBL::Registry';

my $file = '/hps/nobackup2/production/ensembl/anja/release_94/human/protein_function/ensembl.registry';

$registry->load_all($file);

my $species = 'human';

my $sa = $registry->get_adaptor($species, 'core', 'slice');


#my $toplevel_slices = $sa->fetch_all('toplevel', undef, 1);
#foreach my $slice (@$toplevel_slices) {
#  print $slice->seq_region_name, ' ', $slice->get_seq_region_id, "\n";
#}

my $slice_adaptor = $registry->get_adaptor($species, 'otherfeatures', 'slice');
my $translation_adaptor = $registry->get_adaptor($species, 'otherfeatures', 'translation');

my $translation_stable_id = 'NP_001258568.1';
my $translation = $translation_adaptor->fetch_by_stable_id($translation_stable_id);

my $transcript = $translation->transcript;
my $chrom = $transcript->seq_region_name;
print STDERR $chrom, "\n";
my $start = $transcript->seq_region_start;
my $end = $transcript->seq_region_end;
my $strand = $transcript->seq_region_strand;
my $slice = $slice_adaptor->fetch_by_region('toplevel', $chrom,  $start, $end);
my $transcript_mapper = $transcript->get_TranscriptMapper();

my $transcript_stable_id =  $transcript->stable_id;
my $translation_seq = $translation->seq;
my @amino_acids = ();
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
    my $subseq = $slice->subseq($new_start, $new_end, $strand);
    $triplet .= $subseq;
    push @coords, [$coord_start, $coord_end];
  }
  print $triplet, "\n";
}
