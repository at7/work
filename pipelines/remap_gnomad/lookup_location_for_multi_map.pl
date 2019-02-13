use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;
use Bio::EnsEMBL::Registry;
use POSIX;
use Bio::DB::Fasta;
use Array::Utils qw(:all);

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -DB_VERSION => 95,
);
my $species = 'human';
my $dir = '/hps/nobackup2/production/ensembl/anja/release_96/human/remap_gnomad/exomes/';
my $fh = FileHandle->new("$dir/multi_mapping_results.txt", 'r');

my $mapped_features = {};

while (<$fh>) {
  chomp;
  my ($chrom38, $seq_region_id, $start38, $end38, $allele_string38, $variation_name, $variation_id, $chrom37, $start37, $end37, $allele_string37) = split/\t/;
  push @{$mapped_features->{$variation_id}}, {
    seq_region_id => $seq_region_id,
    chrom38 => $chrom38,
    start38 => $start38,
    end38 => $end38,
    allele_string38 => $allele_string38,
    variation_name => $variation_name,
    chrom37 => $chrom37,
    start37 => $start37,
    end37 => $end37,
    allele_string37 => $allele_string37,
    variation_id => $variation_id,
  }
}

$fh->close;

my $fh_log =  FileHandle->new("$dir/log_gnomad_exomes_unmapped_mappings.txt", 'w');
#my $fh_mappings = FileHandle->new("$dir/gnomad_exomes_unmapped_mappings.txt", 'w');
#my $fh_no_mappings = FileHandle->new("$dir/gnomad_exomes_unmapped_no_mappings.txt", 'w');
my $variation_adaptor = $registry->get_adaptor($species, 'variation', 'variation');
my $vfa = $registry->get_adaptor($species, 'variation', 'variationfeature');

foreach my $variation_id (keys %$mapped_features) {
  my @mappings = @{$mapped_features->{$variation_id}};
  my $first_mapping = $mappings[0];
  print $fh_log "GRCH37 ", $first_mapping->{chrom37}, ' ', $first_mapping->{start37}, ' ', $first_mapping->{end37}, ' ', $first_mapping->{allele_string37}, ' ', $first_mapping->{variation_name}, "\n";
  my $count_db_match = 0;
  my @matched_by_db = ();
  foreach my $mapping (@mappings) {
    print $fh_log "    Remapped to GRCH38 ", $mapping->{chrom38}, ' ', $mapping->{start38}, ' ', $mapping->{end38}, ' ', $mapping->{allele_string38}, ' ', $mapping->{variation_name}, "\n";
    my $allele_string38 = $mapping->{allele_string38};
    my $variation_name = $mapping->{variation_name};
    my @vfs = @{$vfa->_fetch_all_by_coords($mapping->{seq_region_id}, $mapping->{start38}, $mapping->{end38}, 0)};
    foreach my $vf (@vfs) {
      my $matched = 0;
      if (a_is_contained_in_b($allele_string38, $vf->allele_string)) {
        $count_db_match++;
        push @matched_by_db, $mapping; 
        print $fh_log "        Matched by DB location ", $vf->seq_region_name, ' ', $vf->seq_region_start, ' ', $vf->seq_region_end, ' ', $vf->allele_string, ' ', $vf->variation_name, "\n";
      }
    }
  }
  print $fh_log "\n";
  if ($count_db_match == 1) {
    my $mapping = $matched_by_db[0];
    my @output = ();
    foreach my $header (qw/chrom38 seq_region_id start38 end38 allele_string38 variation_name chrom37 start37 end37 allele_string37/) {
      push @output, $mapping->{$header};
    }
    print STDERR join("\t", @output), "\n";
  } 
}

$fh_log->close;

sub a_is_contained_in_b {
  my ($allele_string_a, $allele_string_b) = @_;
  # get items from array @a that are not in array @b
  my @a = split('/', $allele_string_a);
  my @b = split('/', $allele_string_b);
  my @minus = array_minus(@a, @b);
  return (!(scalar @minus > 0));
}


#$fh_mappings->close;
#$fh_no_mappings->close;

