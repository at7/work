use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;
use Bio::EnsEMBL::Registry;
use POSIX;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -port => 3337,
  -DB_VERSION => 89,
);

my $species = 'human';

my $slice_adaptor = $registry->get_adaptor($species, 'core', 'slice');

my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/ExAC/multi_allelic', 'w');
my $vcf_file = "/hps/nobackup/production/ensembl/anja/ExAC/ExAC.r1.sites.vep.vcf.gz";
my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);

foreach my $chrom (1..22, 'X', 'Y') {
  my $chrom_slice = $slice_adaptor->fetch_by_region('chromosome', $chrom);
  my $seq_region_start = $chrom_slice->seq_region_start;
  my $seq_region_end = $chrom_slice->seq_region_end;
  $parser->seek($chrom, $seq_region_start, $seq_region_end);
  while ($parser->next) {
    my @alternatives = split(',', $parser->get_raw_alternatives);
    if (scalar @alternatives > 1) {
      my $ids = $parser->get_IDs;
      my $start = $parser->get_raw_start;
      my $end = $parser->get_raw_end;
      my $reference = $parser->get_raw_reference;
      print $fh join("\t", $chrom, $start, $end, join(',', @$ids), $reference, join(',', @alternatives)), "\n";
    }
  }
}
$parser->close;

$fh->close;


