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
  -db_version => 96,
);

my $transcript_adaptor = $registry->get_adaptor('human', 'core', 'transcript');
my $slice_adaptor = $registry->get_adaptor('human', 'core', 'slice');
my $codonTable   = Bio::Tools::CodonTable->new();
my $transcript = $transcript_adaptor->fetch_by_stable_id('ENST00000299335');
my $chrom = $transcript->seq_region_name;

my $strand = $transcript->seq_region_strand;
my $start = $transcript->seq_region_start;
my $end = $transcript->seq_region_end;
print "$start -  $end\n";
my $slice = $slice_adaptor->fetch_by_region('chromosome', $chrom,  $start, $end);
print $slice->start, "\n";
my $translation = $transcript->translation;
print $translation->stable_id, "\n";
my $transcript_mapper = $transcript->get_TranscriptMapper();
print $translation->length, "\n";
foreach my $i (1 .. $translation->length) {
    my @pep_coordinates = $transcript_mapper->pep2genomic($i, $i);
    my $triplet = '';
    my @coords = ();
    foreach my $coord (@pep_coordinates) {
      my $coord_start = $coord->start;
      my $coord_end = $coord->end;
      print "$coord_start $coord_end\n";
      next if ($coord_start <= 0);
      my $new_start = $coord_start - $start + 1;
      my $new_end   = $coord_end   - $start + 1;
      print "    $new_start $new_end\n";
      my $subseq = $slice->subseq($new_start, $new_end, $strand);
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
    if (!$aa) {
      $entry->{aa} = 'X';
    } else {
      $entry->{aa} = $aa;
      my $reverse = ($strand < 0);
    }

  print Dumper($entry), "\n";
  die;


}
