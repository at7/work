=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016-2018] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut


=head1 CONTACT

Please email comments or questions to the public Ensembl
developers list at <http://lists.ensembl.org/mailman/listinfo/dev>.

Questions may also be sent to the Ensembl help desk at
<http://www.ensembl.org/Help/Contact>.

=cut
package Remapping;

use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Sequence qw(reverse_comp);
use Array::Utils qw(:all);

use base ('Bio::EnsEMBL::Hive::Process');

use constant EQUAL => 1;
use constant EQUAL_AFTER_REV_COMP => 2;
use constant NOT_EQUAL => 3;

sub run {
  my $self = shift;
  my $species = $self->param('species');
  my $chrom = $self->param('chrom');
  my $vcf_file = $self->param('vcf_file');
  my $pipeline_dir = $self->param('pipeline_dir');
  my $registry_file = $self->param('registry_file');
  my $population = $self->param('population');
  my $registry = 'Bio::EnsEMBL::Registry';
  $registry->load_all($registry_file);
  my $dbh = $registry->get_DBAdaptor($species, 'variation')->dbc->db_handle;

  my $fh_out = FileHandle->new("$pipeline_dir/$population.chrom$chrom.new_assembly", 'w');
  my $fh_no_mapping = FileHandle->new("$pipeline_dir/$population.chrom$chrom.no_mapping", 'w');
  my $fh_err = FileHandle->new("$pipeline_dir/$population.chrom$chrom.err", 'w');

  my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);
  my $mappings = $self->update_mappings($dbh, $chrom);
  $parser->seek($chrom, 1);

  while ($parser->next) {
    my $reference = $parser->get_reference;
    my @alternatives = @{$parser->get_alternatives};
    my $allele_string = join('/', $reference, @alternatives);
    my $seq_name = $parser->get_seqname;
    my $start = $parser->get_start;
    my $raw_IDs = $parser->get_raw_IDs;
    my @IDs = split(',', $raw_IDs);
    my $qual = $parser->get_raw_score;
    my $filter = $parser->get_raw_filter_results;
    my $info = 'has been removed';
  #      my $info = $parser->get_raw_info; # AC=3;AF=0.00931677;AN=322;NS=161
  ##INFO=<ID=AC,Number=A,Type=Integer,Description="Total number of alternate alleles in called genotypes">
  ###INFO=<ID=AF,Number=A,Type=Float,Description="Estimated Allele Frequencies">
  ###INFO=<ID=AN,Number=1,Type=Integer,Description="Total number of alleles in called genotypes">
  ###INFO=<ID=NS,Number=1,Type=Integer,Description="Number of samples with data">
  ###FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
  ###FORMAT=<ID=AD,Number=.,Type=Integer,Description="Allelic depths for the ref and alt alleles in the order listed">
  #  my $format = $parser->get_raw_formats;
    my $format = 'GT';
    my $samples_info = $parser->get_samples_info;

    my $id_mappings = get_mappings($mappings, $raw_IDs);
    my $variation_id_mappings = $id_mappings->{mappings};
    my @no_mappings = @{$id_mappings->{no_mappings}};
    my $ids_with_mappings = $id_mappings->{ids_with_mappings};

    my $sample_genotypes = $parser->get_samples_genotypes;
    my $samples = $parser->get_samples;

    if (scalar keys %$variation_id_mappings == 0) {
      print $fh_no_mapping "No mappings for $raw_IDs\n";
    } elsif (scalar keys %$variation_id_mappings > 1 ) {
      # need to merge new alleles but keep reference the same!
      print $fh_err "More than 1 mapping for $raw_IDs\n";
    }
    elsif (scalar keys %$variation_id_mappings == 1) {
      foreach my $variation_id (keys %$variation_id_mappings) {
        foreach my $new_location (keys %{$variation_id_mappings->{$variation_id}}) {
          my $new_allele_string = $variation_id_mappings->{$variation_id}->{$new_location};
          my $cmp_result = compare_genotypes($allele_string, $new_allele_string);
          if ($cmp_result == NOT_EQUAL) {
            # check if new allele string is contained in old allele string rev comp or not
            #  C/A/T C/T -> add A to allele string
            my $updated_new_allele_string = containes_new_allele_string($allele_string, $new_allele_string);
            if ($updated_new_allele_string ne $new_allele_string) {
              $new_allele_string = $updated_new_allele_string;
              $cmp_result = compare_genotypes($allele_string, $new_allele_string);
            } else {
              print $fh_err "$raw_IDs $allele_string $new_allele_string $cmp_result\n"
            }
          }
          if ( $cmp_result == EQUAL) {
            my $old_allele_map = get_allele_map($allele_string);
            my $new_allele_map = get_allele_map($new_allele_string);
            my $mapped_sample_genotypes = map_sample_genotypes($sample_genotypes, $old_allele_map, $new_allele_map);
            my $vcf_line = $self->get_vcf_line($new_location, $ids_with_mappings, $new_allele_string, $qual, $filter, $info, $format, $samples, $mapped_sample_genotypes, $population);
            print $fh_out "$vcf_line\n";
          } elsif ($cmp_result == EQUAL_AFTER_REV_COMP) {
            my $old_allele_map = get_allele_map($allele_string);
            my $old_rev_comp_map = get_rev_comp_allele_map($allele_string);
            my $new_allele_map = get_allele_map($new_allele_string);
            my $mapped_sample_genotypes = map_sample_genotypes($sample_genotypes, $old_allele_map, $new_allele_map, $old_rev_comp_map);
            my $vcf_line = $self->get_vcf_line($new_location, $ids_with_mappings, $new_allele_string, $qual, $filter, $info, $format, $samples, $mapped_sample_genotypes, $population);
            print $fh_out "$vcf_line\n";
          } else {
            print $fh_err "$raw_IDs $allele_string $new_allele_string $cmp_result\n"
          }
        }
      }
    }
  }
  $fh_out->close;
  $fh_err->close;
  $fh_no_mapping->close;
}

sub compare_genotypes {
  my $old_allele_string = shift;
  my $new_allele_string = shift;
  if ($old_allele_string eq $new_allele_string) {
    return EQUAL; # the same
  }
  my @old_alleles = split('/', $old_allele_string);
  my @new_alleles = split('/', $new_allele_string);
  if ( !array_diff(@old_alleles, @new_alleles) ) {
    return EQUAL; # same alleles but ref has changed
  }

  my @rev_comp_new_alleles = split('/', $new_allele_string);
  foreach my $allele (@rev_comp_new_alleles) {
    reverse_comp(\$allele);
  }
  if ( !array_diff(@old_alleles, @rev_comp_new_alleles) ) {
    return EQUAL_AFTER_REV_COMP; # alleles have been reverse complemented
  }

  # length difference
  # old must be contained in new
  # get items from array @a that are not in array @b
  my @not_in_new_alleles = array_minus( @old_alleles, @new_alleles);
  if (!@not_in_new_alleles) {
    return EQUAL; # all alleles contained in @new_alleles
  }

  @not_in_new_alleles = array_minus( @old_alleles, @rev_comp_new_alleles);
  if (!@not_in_new_alleles) {
    return EQUAL_AFTER_REV_COMP; # all alleles contained in rev comp new alleles
  }

  return NOT_EQUAL; # none
}

sub reduce_allele_string {
  my $allele_string = shift;
  my $sample_genotypes = shift;
  my $map = {};
  foreach my $sample (keys %$sample_genotypes) {
    foreach my $allele (split('\|', $sample_genotypes->{$sample})) {
      $map->{$allele} = 1;
    }
  }
  my @reduced_allele_string = ();
  foreach my $allele (split('/', $allele_string)) {
    if ($map->{$allele}) {
      push @reduced_allele_string, $allele;
    }
  }
  return join('/', @reduced_allele_string);
}

sub get_vcf_line {
  my ($self, $new_location, $ids_with_mappings, $new_allele_string, $qual, $filter, $info, $format, $samples, $mapped_sample_genotypes, $population) = @_;
  my ($chrom, $pos) = split(':', $new_location);
  my @alleles = split('/', $new_allele_string);
  my @default_alleles = ();
  foreach my $allele (@alleles) {
    push @default_alleles, '.';
  }
  my $default_gt = join('/', @default_alleles);

  my $ref_allele = shift @alleles;
  my $alt_alleles = join(',', @alleles);
  my @genotypes = ();

  foreach my $sample (@$samples) {
    my $gt = $mapped_sample_genotypes->{$sample};

    # deal with ./. genotypes!
    if (! defined $gt) {
      push @genotypes, $default_gt;
    } else {
      push @genotypes, $mapped_sample_genotypes->{$sample};
    }
  }
  #CHROM POS ID REF ALT QUAL FILTER INFO FORMAT genotypes
  $info = allele_frequency($new_allele_string, $mapped_sample_genotypes, $population); 
  if (!$info) {
    $self->warning("No genotypes $new_allele_string $chrom $pos");
    $info = 'No INFO';
  }
  my $line = join("\t", $chrom, $pos, $ids_with_mappings, $ref_allele, $alt_alleles, $qual, $filter, $info, $format, @genotypes);
  return $line;
}

sub allele_frequency {
  my $allele_string = shift;
  my $sample_genotypes = shift;
  my $population = shift;
  my $allele_map = get_allele_map($allele_string);
  ##INFO=<ID=AC,Number=A,Type=Integer,Description="Total number of alternate alleles in called genotypes">
  ###INFO=<ID=AF,Number=A,Type=Float,Description="Estimated Allele Frequencies">
  ###INFO=<ID=AN,Number=1,Type=Integer,Description="Total number of alleles in called genotypes">
  ###INFO=<ID=NS,Number=1,Type=Integer,Description="Number of samples with data">

  my $counts = {};
  my $sample_count = 0;
  my $total_number_of_alleles = 0;
  foreach my $sample (keys %$sample_genotypes) {
    $sample_count++;
    foreach my $index (split('\|', $sample_genotypes->{$sample})) {
      $total_number_of_alleles++;
      $counts->{$index}++;  
    }
  } 

  my @alleles = split('/', $allele_string);
  my @ac = ();
  my @af = ();
  my $ref = shift @alleles;
  if ($total_number_of_alleles == 0) {
    return undef;
  }
  foreach my $allele (@alleles) {
    my $allele_count = $counts->{$allele_map->{$allele}} // 0;
    my $frequency = sprintf("%.4f", $allele_count / $total_number_of_alleles);  
    push @af, $frequency;
    push @ac, $allele_count;
  }
  return "AN\_$population=$total_number_of_alleles;AF\_$population=" . join(',', @af) . ";AC\_$population=" . join(',', @ac) . ";NS\_$population=$sample_count";
}


sub containes_new_allele_string {
  my $allele_string = shift;
  my $new_allele_string = shift;
  my @alleles = split('/', $allele_string);
  my @new_alleles = split('/', $new_allele_string);
  my @not_in_alleles = array_minus(@new_alleles, @alleles);
  if (scalar @not_in_alleles > 0) {
    # try rev comp
    my @rev_comp_new_alleles =  split('/', $new_allele_string);
    foreach my $allele (@rev_comp_new_alleles) {
      reverse_comp(\$allele);
    }
    @not_in_alleles = array_minus(@rev_comp_new_alleles, @alleles);
    if (scalar @not_in_alleles > 0 ) {
      return $new_allele_string;
    } else {
      return add_alleles(\@alleles, \@rev_comp_new_alleles);
    }
  } else {
    return add_alleles(\@alleles, \@new_alleles);
  }
}

sub add_alleles {
  my $from_alleles = shift;
  my $to_alleles = shift;
  # get items from array @a that are not in array @b
  my @not_in_to_alleles = array_minus(@$from_alleles, @$to_alleles);
  foreach my $allele (@not_in_to_alleles) {
    push @$to_alleles, $allele;
  }
  return join('/', @$to_alleles);
}

sub map_sample_genotypes {
  my $sample_genotypes_old = shift;
  my $old_allele_map = shift;
  my $new_allele_map = shift;
  my $old_rev_comp_map = shift;
  my $rev_comp = 0;
  if ($old_rev_comp_map) {
    $rev_comp = 1;
  }
  my $sample_genotypes_new = {};
  foreach my $sample (keys %$sample_genotypes_old) {
    my $old_gt =  $sample_genotypes_old->{$sample};
    my @alleles = split('\|', $old_gt);
    my @new_gt = ();
    foreach my $allele (@alleles) {
      if ($rev_comp) {
        push @new_gt, $new_allele_map->{$old_rev_comp_map->{$allele}};
      } else {
        push @new_gt, $new_allele_map->{$allele};
      }
    }
    $sample_genotypes_new->{$sample} = join('|', @new_gt);
  }
  return $sample_genotypes_new;
}

sub get_allele_map {
  my $allele_string = shift;
  my $allele_map = {};
  my $i = 0;
  foreach my $allele (split('/', $allele_string)) {
    $allele_map->{$allele} = $i;
    $i++;
  }
  return $allele_map;
}

sub get_rev_comp_allele_map {
  my $allele_string = shift;
  my @alleles = split('/', $allele_string);
  my @rev_comp = split('/', $allele_string);
  foreach my $allele (@rev_comp) {
    reverse_comp(\$allele);
  }
  my $allele_map = {};
  for my $i (0 .. $#alleles) {
    $allele_map->{$alleles[$i]} = $rev_comp[$i];
  }
  return $allele_map;
}

sub get_mappings {
  my $mappings = shift;
  my $raw_IDs = shift;
  my @ids = split(',', $raw_IDs);
  my $variation_ids = {};
  my @no_variation_id_mappings = ();
  my @ids_with_mappings = ();
  foreach my $id (@ids) {
    if ($mappings->{$id}) {
      push @ids_with_mappings, $id;
      foreach my $variation_id (keys %{$mappings->{$id}}) {
        foreach my $location (keys %{$mappings->{$id}->{$variation_id}}) {
          $variation_ids->{$variation_id}->{$location} = $mappings->{$id}->{$variation_id}->{$location};
        }
      }
    } else {
      push @no_variation_id_mappings, $id;
    }
  }
  return {no_mappings => \@no_variation_id_mappings, mappings => $variation_ids, ids_with_mappings => join(',', @ids_with_mappings)};
}

sub update_mappings {
  my $self = shift;
  my $dbh = shift;
  my $seq_region_name = shift;
  my $population = lc $self->param('population');
  my $mappings = {};
  my $sth = $dbh->prepare(qq{
    SELECT subsnp_id, variation_id, seq_region_name_new, seq_region_start_new, allele_string_new
    FROM vcf_variation_$population
    WHERE seq_region_name_old = ?
    AND variation_id IS NOT NULL;
  }, {mysql_use_result => 1});

  $sth->execute($seq_region_name);
  my ($subsnp_id, $variation_id, $seq_region_name_new, $seq_region_start_new, $allele_string_new);
  $sth->bind_columns(\($subsnp_id, $variation_id, $seq_region_name_new, $seq_region_start_new, $allele_string_new));
  while ($sth->fetch) {
    $mappings->{$subsnp_id}->{$variation_id}->{"$seq_region_name_new:$seq_region_start_new"} = $allele_string_new;
  }
  $sth->finish;
  return $mappings;
}


1;
