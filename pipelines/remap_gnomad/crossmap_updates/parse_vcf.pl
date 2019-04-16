use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;
use Bio::EnsEMBL::Registry;
use POSIX;
use Bio::DB::Fasta;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -DB_VERSION => 95,
);
my $species = 'human';

my $chrom  = 1;

#my $fasta_db = Bio::DB::Fasta->new('/hps/nobackup2/production/ensembl/anja/gnomad/update_reference_fasta/', -reindex => 0);
#my @ids = $fasta_db->get_all_primary_ids;

my $slice_adaptor = $registry->get_adaptor($species, 'core', 'slice');

#my $vcf_file = '/hps/nobackup2/production/ensembl/anja/gnomad/Exomes/mapping_results/crossmap_mappings/gnomad.exomes.r2.1.sites.grch38.chr1_noVEP.vcf.gz';
#my $output_file = '/hps/nobackup2/production/ensembl/anja/gnomad/crossmap_updates/exome_chr1_tests/gnomad_exomes_chr1_errors.txt';

my $vcf_file = '/hps/nobackup2/production/ensembl/anja/gnomad/20190322/Exomes/mapping_results/gnomad.exomes.r2.1.sites.grch38.chr1_noVEP.vcf.gz';
my $output_file = '/hps/nobackup2/production/ensembl/anja/gnomad/crossmap_updates/exome_chr1_tests/gnomad_exomes_chr1_fixed.txt';

my $fh = FileHandle->new($output_file, 'w');
my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);

my $chrom_slice = $slice_adaptor->fetch_by_region('chromosome', $chrom);
my $seq_region_start = $chrom_slice->seq_region_start;
my $seq_region_end = $chrom_slice->seq_region_end;
$parser->seek($chrom, $seq_region_start, $seq_region_end);
while ($parser->next) {
  my $ids = $parser->get_raw_IDs;
  my $sequence_id = $parser->get_raw_seqname;
  my $start = $parser->get_raw_start;
  my $end = $parser->get_raw_end;
  my $reference = $parser->get_raw_reference;
  my $raw_alternatives = $parser->get_raw_alternatives;
  my $alternatives = $parser->get_alternatives;
  print $fh join("\t", $sequence_id, $start, $end, $reference, $raw_alternatives, $ids), "\n";
}
$parser->close;
$fh->close;

