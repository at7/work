use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;

my $vcf_file = '/hps/nobackup/production/ensembl/anja/release_92/goat/FRCH/FRCH.genus_snps.CHIR1_0.20140928.vcf.gz';
my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);

my $chroms = {};
my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/goat/FRCH/FRCH_chroms_list', 'r');
while (<$fh>) {
  chomp;
  $chroms->{$_} = 1;
}
$fh->close;

$fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/goat/FRCH/FRCH_variants_old_assembly', 'w');

foreach my $chrom (keys %$chroms) {
  $parser->seek($chrom, 1);
  while ($parser->next) {
    my $seq_name = $parser->get_seqname;
    my $start = $parser->get_start;
    my $reference = $parser->get_reference;
    my @alternatives = @{$parser->get_alternatives};
    my $allele_string = join('/', $reference, @alternatives);
    my @IDs = split(',', $parser->get_raw_IDs);
    foreach my $id (@IDs) {
      print $fh join("\t", $seq_name, $start, $allele_string, $id), "\n";
    }
  }
}

$fh->close;
