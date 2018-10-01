use strict;
use warnings;

use FileHandle;

my $connect_mapped_data_id = 'phenotype_feature_id';
my $dir = '/hps/nobackup2/production/ensembl/anja/release_94/chicken/remapping/';
my $file_init_feature = "$dir/dump_features/1.txt";
my $file_filtered_mappings = "$dir/filtered_mappings_1.txt";
my $file_mappings = "$dir/mapping_results/mappings_1.txt";

my $fh_mappings = FileHandle->new($file_mappings, 'r');

my ($stats_failed, $stats_unique_map, $stats_multi_map);

my $mapped = {};

while (<$fh_mappings>) {
  chomp;
  #query_name seq_region_name start end strand map_weight edit_dist score_count algn_score
  #10137:patched    4       127441656       127441755       1       1       1.00000 241M
  #417:complete     4       127285626       127285726       1       293     0.99010 101M
  #10157:upstream   4       128525045       128525544       -1      1       0.99800 277M1I223M
  #10157:downstream 4       129826530       129827031       -1      1       0.99401 213M1D288M
  my ($query_name, $new_seq_name, $new_start, $new_end, $new_strand, $map_weight, $algn_score, $cigar) = split("\t", $_);
  my ($id, $type) = split(':', $query_name);
  $mapped->{$id}->{$type}->{$new_seq_name}->{"$new_start:$new_end:$new_strand"} = $algn_score;
}
$fh_mappings->close();

my $fh_init_feature = FileHandle->new($file_init_feature, 'r');
# this comes from the initial dump from phenotype_feature
my $feature_data = {};
while (<$fh_init_feature>) {
  chomp;
  my $data = read_data($_);
  $feature_data->{$data->{$connect_mapped_data_id}} = $data;
}
$fh_init_feature->close();


my $fh_filtered_mappings = FileHandle->new($file_filtered_mappings, 'w');

foreach my $id (keys %$mapped) {
  my $init_data = $feature_data->{$id};
  my $old_chrom = $init_data->{seq_region_name};
  my $old_start = $init_data->{seq_region_start};
  my $old_end = $init_data->{seq_region_end};
  my $diff = $old_end - $old_start + 1;
  my $types = scalar keys %{$mapped->{$id}}; # upstream, downstream, patched, complete
  my $count_out = 0;
  my @output_lines = ();
  if ($types == 2) { # upstream and downstream mappings
    my $filtered = {};
    foreach my $seq_name (keys %{$mapped->{$id}->{upstream}}) {
      # find pairs
      my $filtered_upstream   = $mapped->{$id}->{upstream}->{$seq_name};
      my $filtered_downstream = $mapped->{$id}->{downstream}->{$seq_name};
      next unless ($filtered_upstream && $filtered_downstream);
      # match up upstream and downstream reads select pairs whose difference matches best with the size (diff) of the originial QTL
      $filtered = match_upstream_downstream($filtered_upstream, $filtered_downstream, $filtered, $diff, $seq_name);
    } 
    # use prior knowledge from previous mapping and prefer same chromosome on which QLT was located in old assembly
    if ($filtered->{$old_chrom}) {
      filter_by_prior($filtered->{$old_chrom}, \@output_lines, {count_out => \$count_out, old_chrom => $old_chrom, id => $id});
    } else {
      # compute best score over all seq_names
      # Get best score for each seq_region
      # Get all seq_regions with best score
      # Get all mappings from seq_regions with best score
      filter_by_best_overall_score($filtered, \@output_lines, {count_out => \$count_out, old_chrom => $old_chrom, id => $id});
    }
  } elsif ($types == 1) { # complete or patched
    foreach my $type (keys %{$mapped->{$id}}) {
      my $mappings = get_patched_or_complete_mappings($mapped->{$id}->{$type}, $old_chrom);
      filter_by_score($mappings, \@output_lines, {count_out => \$count_out, id => $id});
    }
  } else {
    print STDERR "Error for id: $id. More than 2 types\n";
  }
  if ($count_out == 1) {
    $stats_unique_map++;
  } elsif ($count_out > 1 && $count_out <= 5) {
    $stats_multi_map++;
  } elsif ($count_out > 5) {
    $stats_failed++;
  } else {
    $stats_failed++;
  }
  if ($count_out >= 1 && $count_out <= 5) {
    foreach my $line (@output_lines) {
      print $fh_filtered_mappings $line;
    }
  }
}

sub filter_by_score {
  my $mappings = shift;
  my $output_lines = shift;
  my $hash = shift;
  my $count_out = $hash->{count_out};
  my $id = $hash->{id};
  my @sorted_mappings_by_score = sort {$mappings->{$a} <=> $mappings->{$b}} keys(%$mappings);
  my $threshold = $mappings->{$sorted_mappings_by_score[0]};
  foreach my $mapping (@sorted_mappings_by_score) {
    my $score = $mappings->{$mapping};
    if ($score <= $threshold) {
      $$count_out++;
      my ($chrom, $new_start, $new_end, $new_strand) = split(':', $mapping);
      push @$output_lines, "$id\t$chrom\t$new_start\t$new_end\t$new_strand\t$score\n";
    }
  }
}

sub get_patched_or_complete_mappings {
  my $mapped = shift;
  my $old_chrom = shift;
  my $mappings = {};
  if ($mapped->{$old_chrom}) {
    foreach my $coords (keys %{$mapped->{$old_chrom}}) {
      $mappings->{"$old_chrom:$coords"} = $mapped->{$old_chrom}->{$coords};
    }
  } else {
    foreach my $seq_name (keys %$mapped) {
      foreach my $coords (keys %{$mapped->{$seq_name}}) {
        $mappings->{"$seq_name:$coords"} = $mapped->{$seq_name}->{$coords};
      }
    }
  }
  return $mappings;
}


sub match_upstream_downstream {
  my $filtered_upstream = shift;
  my $filtered_downstream = shift;
  my $filtered = shift;
  my $diff = shift;
  my $seq_name = shift;
  foreach my $upstream_mapping (keys %$filtered_upstream) {
    my $upstream_score = $filtered_upstream->{$upstream_mapping};
    my ($up_start, $up_end, $up_strand) = split(':', $upstream_mapping);
    foreach my $downstream_mapping (keys %$filtered_downstream) {
      my $downstream_score = $filtered_downstream->{$downstream_mapping};
      my ($down_start, $down_end, $down_strand) = split(':', $downstream_mapping);
      my $mapping_diff = $down_end - $up_start + 1;
      my $diff_score = abs($mapping_diff - $diff);
      if ($up_strand == $down_strand) {
        if ($up_start > $down_end) {
          ($up_start, $down_end) = ($down_end, $up_start);
        }
        $filtered->{$seq_name}->{"$up_start:$down_end:$down_strand"} = $diff_score;
      }
    }
  }
  return $filtered;
}

sub filter_by_prior {
  my $mappings = shift;
  my $output_lines = shift;
  my $hash = shift;
  my $count_out = $hash->{count_out};
  my $old_chrom = $hash->{old_chrom};
  my $id = $hash->{id};
  my @sorted_diff_score = sort {$mappings->{$a} <=> $mappings->{$b}} keys(%$mappings); # score is defined as difference between previous length of QTL and new length of QTL, the smaller the better
  my $threshold = $mappings->{$sorted_diff_score[0]};
  foreach my $mapping (@sorted_diff_score) {
    my $score = $mappings->{$mapping};
    if ($score <= $threshold) { # consider all mappings with the same score
      $$count_out++;
      my ($new_start, $new_end, $new_strand) = split(':', $mapping);
      push @$output_lines, "$id\t$old_chrom\t$new_start\t$new_end\t$new_strand\t$score\n";
    }
  }
}

sub filter_by_best_overall_score {
  my $filtered = shift;
  my $output_lines = shift;
  my $hash = shift;
  my $count_out = $hash->{count_out};
  my $old_chrom = $hash->{old_chrom};
  my $id = $hash->{id};
  my $seq_region_2_best_score = {};
  # find best mapping score for each seq_region
  foreach my $seq_name (keys %$filtered) {
    my $mappings = $filtered->{$seq_name};
    my @sorted_mappings_by_score = sort {$mappings->{$a} <=> $mappings->{$b}} keys(%$mappings);
    my $best_score = $mappings->{$sorted_mappings_by_score[0]};
    $seq_region_2_best_score->{$seq_name} = $best_score;
  }
  # find seq region with highest mapping
  my @seq_regions_with_best_score = ();
  my @sorted_seq_regions_by_score = sort {$seq_region_2_best_score->{$a} <=> $seq_region_2_best_score->{$b}} keys(%$seq_region_2_best_score);
  my $threshold = $seq_region_2_best_score->{$sorted_seq_regions_by_score[0]};
  foreach my $seq_region (keys %$seq_region_2_best_score) {
    if ($seq_region_2_best_score->{$seq_region} <= $threshold) {
      push @seq_regions_with_best_score, $seq_region;
    } 
  }
  foreach my $new_chrom (@seq_regions_with_best_score) {
    my $mappings = $filtered->{$new_chrom};
    my @sorted_mappings_by_score = sort {$mappings->{$a} <=> $mappings->{$b}} keys(%$mappings);
    my $best_score = $mappings->{$sorted_mappings_by_score[0]};
    foreach my $mapping (@sorted_mappings_by_score) {
      my $score = $mappings->{$mapping};
      if ($score <= $threshold) {
        $$count_out++;
        my ($new_start, $new_end, $new_strand) = split(':', $mapping);
        push @$output_lines, "$id\t$new_chrom\t$new_start\t$new_end\t$new_strand\t$score\n";
      }
    }
  }
}

sub read_data {
  my $line = shift;
  my @key_values = split("\t", $line);
  my $mapping = {};
  foreach my $key_value (@key_values) {
    my ($table_name, $value) = split('=', $key_value, 2);
    $mapping->{$table_name} = $value;
  }
  return $mapping;
}

