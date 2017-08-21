use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Slice qw(split_Slices);

my $registry = 'Bio::EnsEMBL::Registry';

#my $file = '/hps/nobackup/production/ensembl/anja/release_89/debug_human_dumps/ensembl.registry';
#
$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 89,
);

#$registry->load_all($file);

my $species = 'human';

my $vfa = $registry->get_adaptor($species, 'variation', 'variationfeature');
my $sa = $registry->get_adaptor($species, 'core', 'slice');



my @split_sizes = (1e3, 1e4, 1e6);
my $overlap = 0;

my $counts = {};

my $slice = $sa->fetch_by_region('chromosome', 8);

my $first = {};
my $second = {};

my $slice_pieces = split_Slices([$slice], 1e3, $overlap);
foreach my $slice_piece (@$slice_pieces) {
  print STDERR $slice_piece->seq_region_start, ' ', $slice_piece->seq_region_end, "\n";

  my $vfs = $vfa->fetch_all_by_Slice($slice_piece);
  if ((scalar keys %$first) == 0) {
    foreach my $vf (@$vfs) {
      if ($vf->seq_region_start >= $slice_piece->seq_region_start) {
        $first->{$vf->variation_name} = 1;
      }
    }
  } else {
    foreach my $vf (@$vfs) {
#      if ($vf->seq_region_start >= $slice_piece->seq_region_start) {
        if ($first->{$vf->variation_name}) {
          print STDERR "DUP ", $vf->variation_name, "\n";
        }  
#      }
    }
    $first = {};
    foreach my $vf (@$vfs) {
      $first->{$vf->variation_name} = 1;
    }
  }
}




=begin
my $toplevel_slices = $sa->fetch_all('toplevel');
my $seq_region_ids = {};
foreach my $toplevel_slice (@$toplevel_slices) {
  $seq_region_ids->{$toplevel_slice->get_seq_region_id} = $toplevel_slice->seq_region_name;
}


foreach my $seq_region_id (keys %$seq_region_ids) { 
  my $slice = $sa->fetch_by_seq_region_id($seq_region_id);
  my $seq_region_name = $seq_region_ids->{$seq_region_id};
  foreach my $split_size (@split_sizes) {
    my $vf_count = 0;
    my $slice_pieces = split_Slices([$slice], $split_size, $overlap);
    foreach my $slice_piece (@$slice_pieces) {
      my $vfs = $vfa->fetch_all_by_Slice($slice_piece);
      $vf_count += scalar @$vfs;
    }
    $counts->{$seq_region_name}->{$split_size} = $vf_count;
    print STDERR "$seq_region_name $split_size $vf_count\n";
  }
}
=end
=cut
