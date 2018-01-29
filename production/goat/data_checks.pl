use strict;
use warnings;

use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;
use FileHandle;
use Array::Utils qw(:all);

my $data_dir = '/hps/nobackup/production/ensembl/anja/release_92/goat/';

my $files = {
  IRCH => { origin => 'Iran',
            genus => 'IRCH.genus_snps.CHIR1_0.20140928.vcf.gz',
            population => 'IRCH.population_sites.CHIR1_0.20140307.vcf.gz' },

  MOCH => { origin => 'Morocco',
            genus => 'MOCH.genus_snps.CHIR1_0.20140928.vcf.gz',
            population => 'MOCH.population_sites.CHIR1_0.20140307.vcf.gz' },

  AUCH => { origin => 'Australia',
            genus => 'AUCH.genus_snps.CHIR1_0.20140928.vcf.gz', },

  AUFR => { origin => 'France',
            genus => 'FRCH.genus_snps.CHIR1_0.20140928.vcf.gz', },

  ITCH => { origin => 'Italy',
            genus => 'ITCH.genus_snps.CHIR1_0.20140928.vcf.gz' },
};


&map_to_variation_id;
sub map_to_variation_id {

  my $mappings = {};

  my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/goat/ssid_2_variant_id', 'r');
  while (<$fh>) {
    chomp;
    my ($variation_id, $ss_id) = split/\t/;
    $mappings->{$ss_id}->{$variation_id} = 1;
  }
  $fh->close;

  foreach my $population (keys %$files) {
    my $file_type = 'genus';
    my $file = $files->{$population}->{$file_type};
    next if (!$file);
    my $fh = FileHandle->new("$data_dir/$population\_no_variation_id_mapping_$file_type.txt", 'w');
    my $vcf_file = "$data_dir/$file";
    my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);
    while ($parser->next) {
      my @IDs = split(',', $parser->get_raw_IDs);
      my $found_variation_id = 0;
      foreach my $id (@IDs) {
        if ($mappings->{$id}) {
          $found_variation_id = 1;
        }
      }
      if (!$found_variation_id) {
        print $fh join(',', @IDs), "\n";
      }
    }
    $fh->close;
  }
}

sub load_variants_and_gts {
  my $variants = {};
  foreach my $population (keys %$files) {
    my $file = $files->{$population}->{'genus'};
    my $fh = FileHandle->new("$data_dir/$population\_all_GTs_genus.txt", 'r');
    while (<$fh>) {
      chomp;
      #ss1235151892    1       99999786        A/G     G|G:0.8000      G|A:0.2000
      my @values = split/\t/;      
      my $id = $values[0];
      my $allele_string = $values[3];
      $variants->{$id}->{$allele_string} = 1;
    }
    $fh->close;
  }

  my $fh = FileHandle->new("$data_dir/load_ids_gts_old_assembly", 'w');

  foreach my $id (keys %$variants) {
    my @gts = keys %{$variants->{$id}};
    if (scalar @gts > 1) {
      print STDERR "$id ", join(' ', @gts), "\n";
    } else {
      print $fh "$id\t", $gts[0], "\n";
    }
  }  
} 

sub overlap_matrix {
  my @sets = qw/AUCH AUFR ITCH IRCH MOCH/; 
  my $variants = {};
  foreach my $population (keys %$files) {
    my $file = $files->{$population}->{'genus'};
    my $fh = FileHandle->new("$data_dir/$population\_all_variants_genus.txt", 'r');
    while (<$fh>) {
      chomp;
      my ($id, $chrom, $pos) = split/\t/;
      $variants->{$population}->{$id} = 1;
    }
    $fh->close;
  }

  foreach my $p1 (@sets) {
    foreach my $p2 (@sets) {
      next if ($p1 eq $p2);
      # get items from array @a that are not in array @b
      my @a = keys %{$variants->{$p1}};
      my @b = keys %{$variants->{$p2}};
      my @minus = array_minus( @a, @b );
      print STDERR "Variants in $p1 that are not in $p2: ", scalar @minus,"\n";
      foreach my $id (@minus) {
        print STDERR "    $id\n";
      }
    }
  }
}

sub variant_set_overlap {

  my $all_variants = {};
  my $overlap_counts = {};
  my $variant_counts = {};
  my $id2file = {};
  foreach my $population (keys %$files) {
    foreach my $file_type (qw/genus population/) {
      my $file = $files->{$population}->{$file_type};
      next if (!$file);
      print STDERR "$data_dir/$population\_all_variants_$file_type.txt\n";
      my $fh = FileHandle->new("$data_dir/$population\_all_variants_$file_type.txt", 'r');
      my $variant_count = {};
      while (<$fh>) {
        chomp;
        my ($id, $chrom, $pos) = split/\t/;
        $all_variants->{$id} = 1;
        $variant_count->{$id} = 1;
      }
      $fh->close;
      $variant_counts->{"$population\_$file_type"} = scalar keys %$variant_count;
    }
  }
  foreach my $population (keys %$files) {
    foreach my $file_type (qw/genus population/) {
      my $file = $files->{$population}->{$file_type};
      next if (!$file);
      my $fh = FileHandle->new("$data_dir/$population\_all_variants_$file_type.txt", 'r');
      my $variants = {};
      while (<$fh>) {
        chomp;
        my ($id, $chrom, $pos) = split/\t/;
        $variants->{$id} = 1;
      }
      $fh->close;
      my @a = keys %$all_variants;
      my @b = keys %$variants;
      my @intersection = intersect(@a, @b);
      $overlap_counts->{"$population\_$file_type"} = scalar @intersection;
    }
  }

  print STDERR "Count all variants ", scalar keys %$all_variants, "\n";
  foreach my $file (keys %$variant_counts) {
    my $count = $variant_counts->{$file};
    my $overlap = $overlap_counts->{$file};
    print STDERR "$file $count $overlap\n";
  }

}  

sub print_gts {
  foreach my $population (keys %$files) {
    foreach my $file_type (qw/genus population/) {
      my $file = $files->{$population}->{$file_type};
      next if (!$file);
      my $fh = FileHandle->new("$data_dir/$population\_all_GTs_$file_type.txt", 'w');
      my $vcf_file = "$data_dir/$file";
      my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);

      while ($parser->next) {
        my $gt_counts = {};
        my $gts = $parser->get_samples_genotypes;
        my @samples = @{$parser->get_samples};
        foreach my $value (values %$gts) {
          $gt_counts->{$value}++;
        }
        my @gt_frequencies = ();
        foreach my $gt (keys %$gt_counts) {
          my $count = $gt_counts->{$gt};
          my $frequency = sprintf("%.4f", $count / scalar @samples);
          push @gt_frequencies, "$gt:$frequency";
        } 

        my $reference = $parser->get_reference;
        my @alternatives = @{$parser->get_alternatives};
        my $allele_string = join('/', $reference, @alternatives);

        my $seq_name = $parser->get_seqname;
        my $start = $parser->get_start;
        my @IDs = split(',', $parser->get_raw_IDs);
        foreach my $id (@IDs) {
          print $fh join("\t", $id, $seq_name, $start, $allele_string, @gt_frequencies), "\n";
        }
      }
      $fh->close;
    }
  }
}
