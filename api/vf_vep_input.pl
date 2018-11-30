use strict;
use warnings;

use FileHandle;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -port => 3337,
  -db_version => 94,
);

my $stable_id = 'ENST00000281456';


my $transcript_adaptor = $registry->get_adaptor('homo_sapiens', 'core', 'transcript');
my $transcript = $transcript_adaptor->fetch_by_stable_id($stable_id);

my $trv_adaptor = $registry->get_adaptor('homo_sapiens', 'variation', 'transcriptvariation'); 
my $trvs = $trv_adaptor->fetch_all_by_Transcripts_SO_terms([$transcript], ['missense_variant']);

my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/vep_data/input/grch37/cadd_test', 'w');
foreach my $tv (@$trvs) {
  my $vf = $tv->variation_feature;
  my $chrom = $vf->seq_region_name;
  my $start = $vf->seq_region_start;
  my $end = $vf->seq_region_end;
  my $allele_string = $vf->allele_string;
  my $variation_name = $vf->variation_name;
  print $fh join("\t", $chrom, $start, $end, $allele_string, 1), "\n";
}

$fh->close();

#18 52895520 52895520 G/C 1

