use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;
use Bio::EnsEMBL::Registry;

use Bio::EnsEMBL::Variation::Utils::Sequence qw(trim_sequences);

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_95/horse/remapping_vcf/ensembl.registry.oldasm');
my $slice_adaptor = $registry->get_adaptor('horse', 'core', 'slice');


#my $vcf_file = '/hps/nobackup/production/ensembl/anja/release_92/goat/FRCH/FRCH.genus_snps.CHIR1_0.20140928.vcf.gz';
#my $vcf_file = '/hps/nobackup2/production/ensembl/anja/release_95/cow/remapping_vcf/IRBT.population_sites.UMD3_1.20140322_EVA_ss_IDs.vcf.gz';
my $vcf_file = '/hps/nobackup2/production/ensembl/anja/release_95/horse/remapping_vcf/fixed2.vcf.gz';
my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);

my $chroms = {};
#my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/goat/FRCH/FRCH_chroms_list', 'r');
my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/horse/remapping_vcf/chroms_list', 'r');
while (<$fh>) {
  chomp;
  $chroms->{$_} = 1;
}
$fh->close;

$fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/horse/remapping_vcf/horse_variants_old_assembly', 'w');


foreach my $chrom (keys %$chroms) {
  my $ensembl_chrom = $chrom;
  $ensembl_chrom =~ s/chr//;
  my $slice = $slice_adaptor->fetch_by_region('toplevel', $ensembl_chrom);
  my $seq_region_id = $slice->get_seq_region_id;
  my $chrom_end = $slice->seq_region_end;
  $parser->seek($chrom, 1, $chrom_end);
  while ($parser->next) {
    my $seq_name = $parser->get_seqname;
    my $start = $parser->get_start;
    my $raw_start = $parser->get_raw_start;
    my $reference = $parser->get_reference;
    my @alternatives = @{$parser->get_alternatives};
    my $allele_string = join('/', $reference, @alternatives);
    if ($raw_start ne $start) {
      # do some trimming
      my @trimmed_alleles = ();
      my $trimmed_ref = '';
      foreach my $allele (@alternatives) {
        my ($_ref, $_alt, $_start) = @{trim_sequences($reference, $allele, 1, 1, 1)};
        $trimmed_ref = $_ref;
        push @trimmed_alleles, $_alt;
      }
      if ($trimmed_ref eq '-') {
        $start = $raw_start;
      }
      $allele_string = join('/', $trimmed_ref, @trimmed_alleles);
    }
    my @IDs = split(',', $parser->get_raw_IDs);
    foreach my $id (@IDs) {
      $id =~ s/ss//;
      print $fh join("\t", $ensembl_chrom, $seq_region_id, $start, $allele_string, $id), "\n";
    }
  }
}

$fh->close;
