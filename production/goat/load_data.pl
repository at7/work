use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;
use ImportUtils qw(load);


my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup/production/ensembl/anja/release_92/goat/variation_qc/ensembl.registry');

my $dbh = $registry->get_DBAdaptor('goat', 'variation')->dbc->db_handle;



my $TMP_DIR = '/hps/nobackup/production/ensembl/anja/release_92/goat/variants_old_assembly/';
my $tmp_file = "FRCH_variants_old_assembly";
my $result_table = 'vcf_variation_auch';
my $column_names_concat = 'seq_region_name_old,seq_region_start_old,allele_string_old,subsnp_id';
$ImportUtils::TMP_DIR = $TMP_DIR;
$ImportUtils::TMP_FILE = $tmp_file;
load($dbh, ($result_table, $column_names_concat));



sub load_insert {
  my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/goat/load_ids_gts_old_assembly', 'r');
  while (<$fh>) {
    chomp;
    my ($ssid, $allele_string) = split/\t/;
    $dbh->do(qq{Insert into vcf_variation(name, allele_string) values ('$ssid', '$allele_string');}) or die $dbh->errstr;
  }
  $fh->close;
}
