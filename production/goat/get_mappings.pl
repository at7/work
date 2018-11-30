use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::IntVar::Pipeline::NextGen::RemappingVCF::Mapping;


my $species = 'cow';
my $chrom = 6;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_95/cow/remapping_vcf/ensembl.registry.newasm');
my $dbh = $registry->get_DBAdaptor($species, 'variation')->dbc->db_handle;
my $mappings_by_chrom = update_mappings($dbh, $chrom);

print STDERR "Counts ", scalar @$mappings_by_chrom;
my $raw_start = 5499;
my $seq_name = 6;
my @mappings_by_seq_name_and_raw_start = grep {$_->seq_region_name_old eq "$seq_name" && $_->seq_region_start_old == $raw_start && $_->variation_id && $_->seq_region_start_new} @$mappings_by_chrom;

print STDERR " After grep ", scalar @mappings_by_seq_name_and_raw_start, "\n";


sub update_mappings {
  my $dbh = shift;
  my $seq_region_name = shift;
  my @mappings = ();

  my $sth = $dbh->prepare(qq{
    SELECT vcf_variation_id, seq_region_name_old, seq_region_id_old, seq_region_start_old, seq_region_start_padded_old, allele_string_old, allele_string_padded_old, vcf_id, variation_id, seq_region_name_new, seq_region_id_new, seq_region_start_new, allele_string_new
    FROM vcf_variation
    WHERE seq_region_name_old = ?
    AND variation_id IS NOT NULL
    AND seq_region_name_new IS NOT NULL;
  }, {mysql_use_result => 1});

  $sth->execute($seq_region_name);
  my ($vcf_variation_id, $seq_region_name_old, $seq_region_id_old, $seq_region_start_old, $seq_region_start_padded_old, $allele_string_old, $allele_string_padded_old, $vcf_id, $variation_id, $seq_region_name_new, $seq_region_id_new, $seq_region_start_new, $allele_string_new);
  $sth->bind_columns(\($vcf_variation_id, $seq_region_name_old, $seq_region_id_old, $seq_region_start_old, $seq_region_start_padded_old, $allele_string_old, $allele_string_padded_old, $vcf_id, $variation_id, $seq_region_name_new, $seq_region_id_new, $seq_region_start_new, $allele_string_new));
  while ($sth->fetch) {
    my $mapping = Bio::EnsEMBL::IntVar::Pipeline::NextGen::RemappingVCF::Mapping->new(
      -vcf_variation_id => $vcf_variation_id,
      -seq_region_name_old => $seq_region_name_old,
      -seq_region_id_old => $seq_region_id_old,
      -seq_region_start_old => $seq_region_start_old,
      -seq_region_start_padded_old => $seq_region_start_padded_old || undef,
      -allele_string_old => $allele_string_old,
      -allele_string_padded_old => $allele_string_padded_old || undef,
      -vcf_id => $vcf_id,
      -variation_id => $variation_id,
      -seq_region_name_new => $seq_region_name_new,
      -seq_region_id_new => $seq_region_id_new,
      -seq_region_start_new => $seq_region_start_new,
      -allele_string_new => $allele_string_new,
    );
    push @mappings, $mapping;
  }
  $sth->finish;
  my $count = scalar @mappings;
  return \@mappings;
}

