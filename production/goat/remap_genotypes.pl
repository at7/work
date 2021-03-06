use strict;
use warnings;

# bsub5G -J cmp_gt -o cmp_gt.out -e /hps/nobackup/production/ensembl/anja/release_92/goat/test_run.err perl remap_genotypes.pl

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Sequence qw(reverse_comp expand);
use Array::Utils qw(:all);

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup/production/ensembl/anja/release_92/goat/variation_qc/ensembl.registry');
my $dbh = $registry->get_DBAdaptor('goat', 'variation')->dbc->db_handle;

# new VCF line
# #CHROM POS ID REF ALT QUAL FILTER INFO FORMAT genotypes


my $fh_out = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/goat/MOCH.chrom1.new_assembly', 'w');
my $fh_no_mapping = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/goat/MOCH.chrom1.no_mapping', 'w');

my $vcf_file = '/hps/nobackup/production/ensembl/anja/release_92/goat/MOCH.genus_snps.CHIR1_0.20140928.vcf.gz';
my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);

my @chroms = @{get_chroms('/hps/nobackup/production/ensembl/anja/release_92/goat/MOCH_chroms_list')};
my $mappings = {};
foreach my $chrom (@chroms) {
  $mappings = update_mappings($chrom);
  my $count = scalar keys %$mappings;
  if ($count > 0) {
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

      my $id_mappings = get_mappings($raw_IDs);
      my $variation_id_mappings = $id_mappings->{mappings};
      my @no_mappings = @{$id_mappings->{no_mappings}};
      my $ids_with_mappings = $id_mappings->{ids_with_mappings};
     
      my $sample_genotypes = $parser->get_samples_genotypes;
      my $samples = $parser->get_samples;
 
      if (scalar keys %$variation_id_mappings == 0) {
        print $fh_no_mapping "No mappings for $raw_IDs\n";
      } elsif (scalar keys %$variation_id_mappings > 1 ) {
        # need to merge new alleles but keep reference the same!
        print STDERR "More than 1 mapping for $raw_IDs\n";
      } 
        elsif (scalar keys %$variation_id_mappings == 1) {
        foreach my $variation_id (keys %$variation_id_mappings) {
          foreach my $new_location (keys %{$variation_id_mappings->{$variation_id}}) {
            my $new_allele_string = $variation_id_mappings->{$variation_id}->{$new_location};
            my $cmp_result = compare_genotypes($allele_string, $new_allele_string);
            if ($cmp_result == 6) {
              # reduce allele_string?
              # if cmp_result == 6 check that all alleles are actually used!!!!!!! and compute again
              my $reduced_allele_string = reduce_allele_string($allele_string, $sample_genotypes);

              # allele_string could be reduced because of unused alleles
              # check if new allele string is contained in old allele string rev comp or not
              #  C/A/T C/T -> add A to allele string

              if ($reduced_allele_string ne $allele_string) {
                $allele_string = $reduced_allele_string;
                # compute again
                $cmp_result = compare_genotypes($allele_string, $new_allele_string);
              }  else {
                # no change
                my $updated_new_allele_string = containes_new_allele_string($allele_string, $new_allele_string);
                if ($updated_new_allele_string ne $new_allele_string) {
                  $new_allele_string = $updated_new_allele_string;
                  $cmp_result = compare_genotypes($allele_string, $new_allele_string);
                } else {
                  print STDERR "$raw_IDs $allele_string $new_allele_string $cmp_result\n"
                }
              } 
            }

            # if cmp_result == 6 check that all alleles are actually used!!!!!!! and compute again
            #
            #CHROM POS ID REF ALT QUAL FILTER INFO FORMAT genotypes
            if ( $cmp_result == 1 || $cmp_result == 2 || $cmp_result == 4) {
              my $old_allele_map = get_allele_map($allele_string); 
              my $new_allele_map = get_allele_map($new_allele_string);
              my $mapped_sample_genotypes = map_sample_genotypes($sample_genotypes, $old_allele_map, $new_allele_map);
              my $vcf_line = get_vcf_line($new_location, $ids_with_mappings, $new_allele_string, $qual, $filter, $info, $format, $samples, $mapped_sample_genotypes);
              print $fh_out "$vcf_line\n";            
            } elsif ($cmp_result == 3 || $cmp_result == 5) {
              my $old_allele_map = get_allele_map($allele_string); 
              my $old_rev_comp_map = get_rev_comp_allele_map($allele_string);
              my $new_allele_map = get_allele_map($new_allele_string);
              my $mapped_sample_genotypes = map_sample_genotypes($sample_genotypes, $old_allele_map, $new_allele_map, $old_rev_comp_map);
              my $vcf_line = get_vcf_line($new_location, $ids_with_mappings, $new_allele_string, $qual, $filter, $info, $format, $samples, $mapped_sample_genotypes);
              print $fh_out "$vcf_line\n";            
            } else {
              print STDERR "$raw_IDs $allele_string $new_allele_string $cmp_result\n"
            }
          }
        }
      }
    }
    $fh_out->close;
    $fh_no_mapping->close;
    die;
  }  
}

sub get_vcf_line {
  my ($new_location, $ids_with_mappings, $new_allele_string, $qual, $filter, $info, $format, $samples, $mapped_sample_genotypes) = @_;
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
    if (! defined $gt) {
      push @genotypes, $default_gt;
      # deal with ./. genotypes!
#      print STDERR "no gt for $sample $chrom $pos $ids_with_mappings\n";
    } else {
      push @genotypes, $mapped_sample_genotypes->{$sample};
    }
  }
  #CHROM POS ID REF ALT QUAL FILTER INFO FORMAT genotypes
  my $line = join("\t", $chrom, $pos, $ids_with_mappings, $ref_allele, $alt_alleles, $qual, $filter, $info, $format, @genotypes);
  return $line;
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
    # if ./. ...
    my $old_gt =  $sample_genotypes_old->{$sample};
    if ($old_gt =~ /\./) {
      $sample_genotypes_new->{$sample} = $old_gt;
    } else {
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

sub compare_genotypes {
  my $old_allele_string = shift;
  my $new_allele_string = shift;

  if ($old_allele_string eq $new_allele_string) {
    return 1; # the same
  }

  my @old_alleles = split('/', $old_allele_string);
  my @new_alleles = split('/', $new_allele_string);

  if ( !array_diff(@old_alleles, @new_alleles) ) {
    return 2; # same alleles but ref has changed
  }

  my @rev_comp_new_alleles = split('/', $new_allele_string);
  foreach my $allele (@rev_comp_new_alleles) {
    reverse_comp(\$allele);
  }
  
  if ( !array_diff(@old_alleles, @rev_comp_new_alleles) ) {
    return 3; # alleles have been reverse complemented
  }

  # length difference
  # old must be contained in new
  # get items from array @a that are not in array @b
  my @minus = array_minus( @old_alleles, @new_alleles);
  if (!@minus) {
    return 4; # all alleles contained in @new_alleles
  }

  @minus = array_minus( @old_alleles, @rev_comp_new_alleles);
  if (!@minus) {
    return 5; # all alleles contained in rev comp new alleles
  }

  return 6; # none
}

sub get_mappings {
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
  my $seq_region_name = shift;
  my $mappings = {};
  my $sth = $dbh->prepare(qq{
    SELECT subsnp_id, variation_id, seq_region_name_new, seq_region_start_new, allele_string_new
    FROM vcf_variation_moch
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

sub get_chroms {
  my $file = shift;
  my @chroms = ();
  my $fh = FileHandle->new($file, 'r');
  while (<$fh>) {
    chomp;
    push @chroms, $_;
  }
  $fh->close;
  return \@chroms;
}
