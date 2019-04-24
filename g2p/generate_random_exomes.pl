use strict;
use warnings;

use FileHandle;

my $background_gene_count = 100;
my $variant_per_gene_count = 20;
my $suspect_gene_count = 1;

# choose 100 random genes
#   choose variants
#   assign genotypes randomly
# choose 2 g2p genes
#   choose variants with low frequencies
#   assign genotypes
my $dir = '/hps/nobackup2/production/ensembl/anja/G2P/test_data/';
my $random_dir = "$dir/random/";
my @vcf_header = ('#CHROM', 'POS', 'ID', 'REF', 'ALT', 'QUAL', 'FILTER', 'INFO', 'FORMAT');

my $all_genes = "$dir/sorted_gene_list_minus_g2p";
my $g2p_genes = "$dir/sorted_suspect_gene_list";
my $g2p_variants = "$dir/suspect_gnomad_grch37.vcf.gz";
my $background_variants = "$dir/master_1kg_grch37.vcf.gz";

my $row_count_all_genes = get_file_row_count($all_genes);
my $row_count_g2p_genes = get_file_row_count($g2p_genes);

my $random_numbers = get_random_numbers($background_gene_count, $row_count_all_genes);
my $random_background_regions = get_random_regions($random_numbers, $all_genes);

my $individual_name = 'P1';
print_random_vcf($random_background_regions, $individual_name);

sub print_random_vcf {
  my $background_regions = shift;
  my $individual_name = shift;
#  my $g2p_regions = shift; 
  my $vcf = "$random_dir/$individual_name.vcf";
  my $fh = FileHandle->new($vcf, 'w');
  print $fh join("\t", @vcf_header) . "\t$individual_name\n";
  foreach my $region (@$background_regions) {
    my @rows = @{get_random_tabix_rows($background_variants, $region)};
    foreach (@rows) {
      print $fh $_;
    }
  }

  # add g2p variants



  $fh->close; 

  


}

sub get_random_regions {
  my $random_numbers = shift;
  my $file = shift; 
  my $fh = FileHandle->new($file, 'r');
  my $counter = 1;
  my @regions = ();
  while (<$fh>) {
    chomp;
    my @values = split;
    my ($chr, $start, $end) = ($values[0], $values[1], $values[2]);
    if (grep {$_ == $counter} @$random_numbers) {
      push @regions, "$chr:$start-$end";
    }
    $counter++
  }
  $fh->close;
  return \@regions;
}


sub get_random_numbers {
  my $random_number_count = shift;
  my $max_value = shift;
  my @random_numbers = ();
  while (scalar @random_numbers <= $random_number_count) {
    push @random_numbers, int(rand($max_value)) + 1;
  }
  return \@random_numbers;
}

sub get_file_row_count {
  my $file = shift;
  my ($all_entries) = split(' ', `wc -l $file`); 
  return $all_entries;
}

sub get_tabix_row_count {
  my $file = shift;
  my $region = shift;
  my @rows = `tabix $file $region`;
  return scalar @rows;
}

sub get_tabix_rows {
  my $file = shift;
  my $region = shift;
  my @rows = `tabix $file $region`;
  return \@rows;
}

sub get_random_tabix_rows {
  my $file = shift;
  my $region = shift;
  my $row_count = get_tabix_row_count($file, $region);
  my $random_numbers = get_random_numbers($variant_per_gene_count, $row_count);
  my $tabix_rows = get_tabix_rows($file, $region);
  my $count = 1;
  my @rows = ();
  my @gts = ('0/1', '1/1');
  foreach my $tabix_row (@$tabix_rows) {
    if (grep {$count == $_} @$random_numbers) {
      chomp($tabix_row);
      push @rows, $tabix_row . "\tGT\t" . $gts[ rand @gts ] . "\n";
    }
    $count++;
  } 
  return \@rows;
}




