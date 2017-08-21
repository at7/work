use strict;
use warnings;

use ImportUtils qw(load);
use Bio::EnsEMBL::Variation::DBSQL::DBAdaptor;
use DBI;

my $vdba_newasm = new Bio::EnsEMBL::Variation::DBSQL::DBAdaptor(
  -host   => 'mysql-ens-var-prod-1.ebi.ac.uk',
  -user   => 'ensadmin',
  -pass   => 'ensembl',
  -port   => 4449,
  -dbname => 'homo_sapiens_variation_90_37_seh',
);

my $dbc = $vdba_newasm->dbc;

my $dir_newasm = '/hps/nobackup/production/ensembl/anja/dbSNP150cp/';
my $result_table = 'variation_feature_dbSNP150';
my $column_names = 'variation_name,seq_region_id,seq_region_start,seq_region_end,allele_string';


my $file;
opendir(DIR, $dir_newasm) or die "can't opendir $dir_newasm: $!";
while (defined($file = readdir(DIR))) {
  if ( $file !~ /^\./) {
    my $TMP_DIR = $dir_newasm;
    my $tmp_file = $file;
    $ImportUtils::TMP_DIR = $TMP_DIR;
    $ImportUtils::TMP_FILE = $tmp_file;
    load($dbc, ($result_table, $column_names));
  }
}
closedir(DIR);
