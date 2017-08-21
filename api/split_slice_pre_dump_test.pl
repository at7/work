use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Slice qw(split_Slices);
use FileHandle;

my $global_vf_count_in_species = 5_000_000; # if number of vf in a species exceeds this we need to split up dumps
my $max_vf_load = 2_000_000; # group slices together until the vf count exceeds max_vf_load
my $vf_per_slice = 2_000_000; # if number of vf exceeds this we split the slice and dump for each split slice
my $max_split_slice_length = 5e6;
my $gvf_dump_split_slice_length = 1e5;
my $overlap = 1;

my $registry = 'Bio::EnsEMBL::Registry';
my $file = '/hps/nobackup/production/ensembl/anja/release_90/ensembl.registry.v2';
$registry->load_all($file);
my $vdbas = $registry->get_all_DBAdaptors(-group => 'variation');

foreach my $vdba (@$vdbas) {
  my $species_name = $vdba->species();
    
$species_name = lc $species_name;
  print STDERR "'$species_name',", "\n";
  next;
  next if ($species_name eq 'Ovis_aries');
  my $global_vf_count = get_global_vf_count($species_name);

  if ($global_vf_count > $global_vf_count_in_species) {
    my $covered_seq_regions_counts = get_covered_seq_regions($species_name);
    my $current_vf_load = 0;
    my @seq_region_ids = ();
    while (my ($seq_region_id, $vf_count) = each %$covered_seq_regions_counts) {
      if ($vf_count > $vf_per_slice) {
        split_slice($seq_region_id, $vf_count, $species_name);
      } else {
        if (($current_vf_load + $vf_count) > $max_vf_load) {
          push @seq_region_ids, $seq_region_id;
          print STDERR "$species_name Join seq_regions: ", join(', ', @seq_region_ids), "\n";
          @seq_region_ids = ();
          $current_vf_load = 0;
        } else {
          push @seq_region_ids, $seq_region_id;
          $current_vf_load += $vf_count;
        }
      }
    }
  }
}

sub split_slice {
  my $seq_region_id = shift;
  my $global_vf_count = shift;
  my $species_name = shift;

  my $sa = $registry->get_adaptor($species_name, 'core', 'slice');
  my $vfa = $registry->get_adaptor($species_name, 'variation', 'variationfeature');

  my $slice = $sa->fetch_by_seq_region_id($seq_region_id);
  my $slice_end = $slice->seq_region_end;
  my $seq_region_name = $slice->seq_region_name;
  my $vf_count = 0;
  my $duplicated = {};
  my $global_pieces = split_Slices([$slice], $max_split_slice_length, $overlap);
  foreach my $global_slice (@$global_pieces) {
    my $slice_pieces = split_Slices([$global_slice], $gvf_dump_split_slice_length, $overlap);
    foreach my $slice_piece (@$slice_pieces) {
      my $slice_piece_start = $slice_piece->seq_region_start;
      my $slice_piece_end = $slice_piece->seq_region_end;
      # if slice_piece_end == $slice->length... extend slice_piece_end to include all remaining variants
      my $included = {};
      my $vfs = $vfa->fetch_all_by_Slice($slice_piece);
      foreach my $vf (@$vfs) {
        my $vf_start = $vf->seq_region_start;
        my $vf_end = $vf->seq_region_end;
        my $variant_name = $vf->variation_name;

        if ($vf_end < $vf_start) {
          ($vf_start, $vf_end) = ($vf_end, $vf_start);
        } 
        if ($vf_start >= $slice_piece_start) {
          next if ($vf_start == $slice_piece_end && $vf_end >= $slice_piece_end && $slice_piece_end != $slice_end);
          if ($duplicated->{$variant_name}) {
            print STDERR "duplicatced $species_name $seq_region_name $slice_piece_start $slice_piece_end $vf_start $vf_end $variant_name\n";
          } else {
            $included->{$variant_name} = 1;
            $vf_count++;
          }
        } else { 
          if (!$duplicated->{$variant_name}) {
            print STDERR "missing $species_name $seq_region_name $slice_piece_start $slice_piece_end $vf_start $vf_end $variant_name\n";
          }
        }
      } # end slice piece
      $duplicated = $included;
    }
  } # end global slice
  print STDERR ">>>$species_name $seq_region_name $vf_count $global_vf_count\n";
}

sub get_covered_seq_regions {
  my $species = shift;
  my $counts = {};
  my $fh = FileHandle->new("/hps/nobackup/production/ensembl/anja/release_90/split_slice_statistics/$species", 'r');    
  while (<$fh>) {
    chomp;
    my ($seq_region_name, $seq_region_id, $vf_count, $sub_slices) = split/\t/;
    if ($vf_count > 0) {
      $counts->{$seq_region_id} = $vf_count;
    }
  }
  $fh->close();
  return $counts;
}

sub get_global_vf_count {
  my $species = shift;
  my $counts = 0;
  my $fh = FileHandle->new("/hps/nobackup/production/ensembl/anja/release_90/split_slice_statistics/$species", 'r');    
  while (<$fh>) {
    chomp;
    my ($seq_region_name, $seq_region_id, $vf_count, $sub_slices) = split/\t/;
    if ($vf_count > 0) {
      $counts += $vf_count;
    }
  }
  $fh->close();
  return $counts;
}

