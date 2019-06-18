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
  -db_version => 96,
);
my $species = 'human';


#my $fasta_db = Bio::DB::Fasta->new('/hps/nobackup2/production/ensembl/anja/gnomad/update_reference_fasta/', -reindex => 0);
#my @ids = $fasta_db->get_all_primary_ids;

my $slice_adaptor = $registry->get_adaptor($species, 'core', 'slice');

my $vcf_dir = '/nfs/production/panda/ensembl/variation/data/gnomAD/170228/GRCh38/exomes/';
my $dir = '/hps/nobackup2/production/ensembl/anja/crossmap_counting_errors/';
my $fh = FileHandle->new("$dir/mapping_errors.txt", 'w');
my $vcf_file = "$vcf_dir/gnomad.exomes.r2.0.1.sites.GRCh38.noVEP.vcf.gz";
my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);

foreach my $chrom (1..22, 'X', 'Y', 'MT') {
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
    if (grep {$_ eq $reference} @$alternatives) {
      print $fh join("\t", $sequence_id, $start, $end, $reference, $raw_alternatives, 'alt:', @$alternatives, $ids), "\n";
    }
  }
}
$parser->close;
$fh->close;
