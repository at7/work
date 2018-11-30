use strict;
use warnings;


use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Slice qw(split_Slices);
use FileHandle;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 94,
);

my $slice_adaptor = $registry->get_adaptor('mouse', 'core', 'slice');
my $rf_adaptor = $registry->get_adaptor('mouse', 'funcgen', 'RegulatoryFeature');
my $mf_adaptor = $registry->get_adaptor('mouse', 'funcgen', 'MotifFeature');


my $slice = $slice_adaptor->fetch_by_region('chromosome', '1');

#{"seq_region_end" => 84988627,"seq_region_name" => 17,"seq_region_start" => 79989297}
#my $slice = $slice_adaptor->fetch_by_region('toplevel', '17', 79989297, 84988627);
#my $slice_end = $slice->seq_region_end;
#print $slice_end, "\n";
my $max_split_slice_length = 5e6;
my $overlap = 0;

my $slice_pieces = split_Slices([$slice], $max_split_slice_length, $overlap);
my $hash0 = {};
my $hash1 = {};

my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/mouse/funcgen/regulatory_feature_split_slice_chrom1', 'w');

foreach my $slice_piece (@$slice_pieces) {
  my $slice_piece_start = $slice_piece->seq_region_start;
  my $slice_piece_end = $slice_piece->seq_region_end;
  print STDERR "$slice_piece_start $slice_piece_end\n";
  my @motif_features = grep { $_->seq_region_end < $slice_piece_end  } @{$mf_adaptor->fetch_all_by_Slice($slice_piece)};

  foreach my $rf (@motif_features) {
    if ($hash1->{$rf->stable_id}) {
      print STDERR "Already in hash ", $rf->stable_id, "\n";
    }
    $hash1->{$rf->stable_id} = 1;
    if ($hash0->{$rf->stable_id}) {
      print STDERR "Duplicate value ", $rf->stable_id, ' ', $rf->seq_region_start, ' ', $rf->seq_region_end,  "\n";
    }
    print $fh $rf->stable_id, "\n";
  }

  $hash0 = $hash1;
  $hash1 = {}; 
}
$fh->close();
=end
=cut
