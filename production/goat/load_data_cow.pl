use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;
use ImportUtils qw(load);


my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_95/cow/remapping_vcf/ensembl.registry.newasm');

my $dbh = $registry->get_DBAdaptor('cow', 'variation')->dbc->db_handle;

my $TMP_DIR = '/hps/nobackup2/production/ensembl/anja/release_95/cow/remapping_vcf/';
my $tmp_file = "cow_variants_old_assembly";
my $result_table = 'vcf_variation';
my $column_names_concat = 'seq_region_name_old,seq_region_id_old, seq_region_start_old, seq_region_start_padded_old, allele_string_old,allele_string_padded_old';
$ImportUtils::TMP_DIR = $TMP_DIR;
$ImportUtils::TMP_FILE = $tmp_file;
load($dbh, ($result_table, $column_names_concat));
