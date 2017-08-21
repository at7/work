use strict;
use warnings;

use Bio::EnsEMBL::Variation::Utils::Sequence qw(get_3prime_seq_offset trim_sequences);
use FileHandle;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -port => 3337,
  -DB_VERSION => 89,
);

my $species = 'human';

my $slice_adaptor = $registry->get_adaptor($species, 'core', 'slice');
my $vfa = $registry->get_adaptor($species, 'variation', 'variationfeature');

my $seq_region_ids = {};

foreach my $chrom (1..22, 'X', 'Y') {
  my $chrom_slice = $slice_adaptor->fetch_by_region('chromosome', $chrom);
  my $seq_region_id = $chrom_slice->get_seq_region_id;
  $seq_region_ids->{$chrom} = $seq_region_id;
}

my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/ExAC/multi_allelic', 'r');
my $fh_out = FileHandle->new('/hps/nobackup/production/ensembl/anja/ExAC/multi_allelic_after_trim_evdn', 'w');

my $empty_to_dash = 1;

# chrom start end alleles end_first trim_start trim_end trim_allels trim_name trim evidence end_first

while (<$fh>) {
  chomp;
  my ($chrom, $vcf_start, $vcf_end, $id, $ref_allele, $alt_alleles) = split/\t/;
  foreach my $alt_allele (split(',', $alt_alleles)) {
    foreach my $end_first (0, 1) {
      my ($new_ref_allele, $new_alt_allele, $new_start, $new_end, $changed) = @{trim_sequences($ref_allele, $alt_allele, $vcf_start, $vcf_end, $empty_to_dash, $end_first)};
      my $existing_vfs = $vfa->_fetch_all_by_coords($seq_region_ids->{$chrom}, $new_start, $new_end, 0);
      if (@$existing_vfs > 0) {
        foreach my $vf (@$existing_vfs) {
          my ($name, $existing_alleles, $evidence) = ('\N', '\N', '\N');
          $name = $vf->variation_name;
          $existing_alleles = $vf->allele_string;
          $evidence = join(',', @{$vf->get_all_evidence_values});
          print $fh_out join("\t", $chrom, $vcf_start, $vcf_end, "$ref_allele/$alt_allele", $id,  $new_start, $new_end, "$new_ref_allele/$new_alt_allele", $end_first, $name, $existing_alleles, $evidence), "\n";
        }
      } else {
        print $fh_out join("\t", $chrom, $vcf_start, $vcf_end, "$ref_allele/$alt_allele", $id, $new_start, $new_end, "$new_ref_allele/$new_alt_allele", $end_first, '\N', '\N', '\N'), "\n";
      }
    }
  }
}

$fh_out->close;
$fh->close;

