use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;
use Bio::EnsEMBL::Registry;

use Bio::EnsEMBL::Variation::Utils::Sequence qw(trim_sequences);

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_95/cow/remapping_vcf/ensembl.registry.oldasm');
my $slice_adaptor = $registry->get_adaptor('cow', 'core', 'slice');

my $vcf_file = '/hps/nobackup2/production/ensembl/anja/release_95/cow/remapping_vcf/IRBT.population_sites.UMD3_1.20140322_EVA_ss_IDs.vcf.gz';
my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);

my $chroms = {};
my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/cow/remapping_vcf/chroms_list', 'r');
while (<$fh>) {
  chomp;
  $chroms->{$_} = 1;
}
$fh->close;

$fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/cow/remapping_vcf/cow_variants_old_assembly', 'w');

foreach my $chrom (keys %$chroms) {
  my $ensembl_chrom = $chrom;
  $ensembl_chrom =~ s/chr//;
  my $slice = $slice_adaptor->fetch_by_region('toplevel', $ensembl_chrom);
  my $seq_region_id_old = $slice->get_seq_region_id;
  my $chrom_end = $slice->seq_region_end;
  $parser->seek($chrom, 1, $chrom_end);
  while ($parser->next) {
    my $seq_name_old = $parser->get_seqname;
    my $start_old = $parser->get_start;
    my $start_padded_old = $parser->get_raw_start;
    my $reference = $parser->get_reference;
    my @alternatives = @{$parser->get_alternatives};
    my $allele_string = join('/', $reference, @alternatives);
    my $allele_string_padded = '';
    if ($start_old != $start_padded_old) {
      $allele_string_padded = $allele_string;
      # do some trimming
      my @trimmed_alleles = ();
      my $trimmed_ref = '';
      foreach my $allele (@alternatives) {
        my ($_ref, $_alt, $_start) = @{trim_sequences($reference, $allele, 1, 1, 1)};
        $trimmed_ref = $_ref;
        push @trimmed_alleles, $_alt;
      }
      $allele_string = join('/', $trimmed_ref, @trimmed_alleles);
    }
    print $fh join("\t", $ensembl_chrom, $seq_region_id_old, $start_old, $start_padded_old, $allele_string, $allele_string_padded), "\n";
  }
}

$fh->close;
