use strict;
use warnings;

use FileHandle;


my $lookup = {};
my $ids = {};
my $dir =  '/hps/nobackup2/production/ensembl/anja/release_94/dog/remapping/';
my $fh_lookup = FileHandle->new("$dir/dump_features/lookup_1.txt", 'r');
while (<$fh_lookup>) {
  chomp;
  foreach my $coord (split(';', $coords)) {
    my ($key, $value) = split('=', $coord);
    $lookup->{"$vf_id\_1"}->{$key} = $value;
    $lookup->{"$vf_id\_-1"}->{$key} = $value;
    $ids->{$vf_id} = 1;
  }
}
$fh_lookup->close();

my $fh_mappings = FileHandle->new("$dir/mapping_results/mappings_1.txt", 'r');

my ($stats_failed, $stats_unique_map, $stats_multi_map);

my $mapped = {};
my $mapped_strand = {};
while (<$fh_mappings>) {
  chomp;
  #feature_id-coord, coord: outer_start seq_region_start inner_start inner_end seq_region_end outer_end

  #107100:upstream 1       460501  461001  1       6       1       496     0.99001996007984
  #query_name seq_region_name start end strand map_weight edit_dist score_count algn_score
  #102027-seq_region_start 10      44974586        44974758        1       145     1       274     score=0.850746268656716 173M28H
  my ($query_name, $new_seq_name, $new_start, $new_end, $new_strand, $map_weight, $algn_score, $cigar_str) = split("\t", $_);

  my ($id, $coord) = split('-', $query_name);
  $id = "$id\_$new_strand";
  if ($lookup->{$id}->{seq_region_name} eq "$new_seq_name") {
    $mapped->{$id}->{$coord}->{$new_start} = $algn_score;
  }
}

$fh_mappings->close();

my $filtered_mappings = {};
foreach my $id (keys %$mapped) {
  foreach my $coord_type (keys %{$mapped->{$id}}) {

    my $mappings = $mapped->{$id}->{$coord_type};
    my @coord_2_scores = sort { $mappings->{$b} <=> $mappings->{$a} } keys %$mappings;
    my $algn_score_threshold = 0.5;
    if ($mappings->{$coord_2_scores[0]} == 1.0) {
      $algn_score_threshold = 1.0;
    }
    my $count_exceed_threshold = grep {$_ >= $algn_score_threshold} values %$mappings;

    if ($count_exceed_threshold > 1) {
      my $prev_mapping = $lookup->{$id}->{$coord_type};
      my $mapped_location = best_mapping($algn_score_threshold, $prev_mapping, $mappings);
      $filtered_mappings->{$id}->{$coord_type}->{$mapped_location} = $mappings->{$mapped_location};
    } else {
      foreach my $coord (@coord_2_scores) {
        my $score = $mappings->{$coord};
        if ($score >= $algn_score_threshold) {
          $filtered_mappings->{$id}->{$coord_type}->{$coord} = $score;
        }
      }
    }
  }
}

my $final_mappings = {};
my $failed_mappings = {};
foreach my $id (keys %$lookup) {
  my @prev_coord_types = grep {$_ ne 'seq_region_name'} keys %{$lookup->{$id}};
  my @new_coord_types =  keys %{$filtered_mappings->{$id}};

  if (overlap(\@prev_coord_types, \@new_coord_types)) {
    my @start_order = qw/outer_start seq_region_start inner_start/;
    my @end_order = qw/inner_end seq_region_end outer_end/;
    my $start_coords_in_order = coords_are_in_order(\@start_order, $filtered_mappings->{$id});
    my $end_coords_in_order = coords_are_in_order(\@end_order, $filtered_mappings->{$id});
    if (!($start_coords_in_order && $end_coords_in_order)) {
      $failed_mappings->{$id} = 'Coords not in order';
      next;
    }
    # check start coords are smaller than end coords
    my $start = get_start($filtered_mappings->{$id}->{seq_region_start});
    my $end = get_start($filtered_mappings->{$id}->{seq_region_end});
    if ($end < $start) {
      my $swap_map = {
        'outer_start'      => 'inner_end',
        'seq_region_start' => 'seq_region_end',
        'inner_start'      => 'outer_end',

        'inner_end'        => 'outer_start',
        'seq_region_end'   => 'seq_region_start',
        'outer_end'        => 'inner_start',
      };
      my @order = qw/outer_start seq_region_start inner_start inner_end seq_region_end outer_end/;
      my $after_swap_mappings = {};
      foreach my $c (@order) {
        $final_mappings->{$id}->{$c} = get_start($filtered_mappings->{$id}->{$swap_map->{$c}});
      }
      next;
    }
    foreach my $c (@new_coord_types) {
      my $start = get_start($filtered_mappings->{$id}->{$c});
      $final_mappings->{$id}->{$c} = $start;
    }
  } else {
    $failed_mappings->{$id} = 'Incomplete mappings';
  }
}

# check if there are mappings to forward and reverse strand

my $fh_filtered_mappings = FileHandle->new('filtered_mappings', 'w');
my $already_stored = {};
foreach my $id (keys %$final_mappings) {
  my ($svf_id, $strand) = split('_', $id);
  next if ($already_stored->{$svf_id});
  my @values = ();
  my $seq_region_name = $lookup->{$id}->{seq_region_name};
  push @values, "seq_region_name=$seq_region_name";
  push @values, "structural_variation_feature_id=$svf_id";
  push @values, "seq_region_strand=$strand";
  foreach my $coord (keys %{$final_mappings->{$id}}) {
    my $start = $final_mappings->{$id}->{$coord};
    push @values, "$coord=$start";
  }
  print $fh_filtered_mappings join("\t", @values), "\n";
  $already_stored->{$svf_id} = 1;
}

$fh_filtered_mappings->close();

sub get_start {
  my $coord = shift;
  if ($coord) {
    my @keys = keys %$coord;
    return $keys[0];
  }
  return 0;
}

sub best_mapping {
  my $threshold = shift;
  my $prev_location = shift;
  my $new_mappings = shift;
  my $new_mapping = '';
  my $diff = 1_000_000_000;

  foreach my $start (keys %$new_mappings) {
    my $score = $new_mappings->{$start};
    if ($score >= $threshold) {
      my $new_diff = abs($prev_location - $start);
      if ($diff > $new_diff) {
        $diff = $new_diff;
        $new_mapping = $start;
      }
    }
  }
  return $new_mapping;
}

sub coords_are_in_order {
  my $order = shift;
  my $mappings = shift;

  for (my $i = 0; $i < scalar @$order - 1; $i++) {
    my $a_coord = $order->[$i];
    my $b_coord = $order->[$i + 1];
    my $a_start = get_start($mappings->{$a_coord});
    my $b_start = get_start($mappings->{$b_coord});
    if ($a_start && $b_start) {
      if ($a_start > $b_start) {
        return 0;
      }
    }
  }
  return 1;
}
sub overlap {
  my $a = shift;
  my $b = shift;
  return (scalar @$a == scalar @$b);
}

sub get_strands {
  my $mapped_strand = shift;
  my $filtered_coord = shift;
  my %strands;
  foreach my $coord_type (keys %$filtered_coord) {
    foreach my $coord (keys %{$filtered_coord->{$coord_type}}) {
      $strands{$mapped_strand->{$coord_type}->{$coord}} = 1;
    }
  }
  return [ keys %strands ];
}




