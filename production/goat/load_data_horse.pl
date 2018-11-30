use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;
use ImportUtils qw(load);


my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_95/horse/remapping_vcf/ensembl.registry.newasm');

my $dbh = $registry->get_DBAdaptor('horse', 'variation')->dbc->db_handle;

my $TMP_DIR = '/hps/nobackup2/production/ensembl/anja/release_95/horse/remapping_vcf/';
my $tmp_file = "horse_variants_old_assembly";
my $result_table = 'vcf_variation';
my $column_names_concat = 'seq_region_name_old,seq_region_start_old,allele_string_old,subsnp_id';
$ImportUtils::TMP_DIR = $TMP_DIR;
$ImportUtils::TMP_FILE = $tmp_file;
load($dbh, ($result_table, $column_names_concat));




=begin
CREATE TABLE `vcf_variation_irbt` (
  `vcf_variation_moch_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `seq_region_name_old` varchar(50) DEFAULT NULL,
  `seq_region_start_old` int(11) DEFAULT NULL,
  `allele_string_old` varchar(50) DEFAULT NULL,
  `subsnp_id` int(10) unsigned DEFAULT NULL,
  `variation_id` int(10) unsigned DEFAULT NULL,
  `seq_region_name_new` varchar(50) DEFAULT NULL,
  `seq_region_start_new` int(11) DEFAULT NULL,
  `allele_string_new` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`vcf_variation_moch_id`),
  KEY `variation_idx` (`variation_id`),
  KEY `subsnp_idx` (`subsnp_id`),
  KEY `seq_region_name_old_idx` (`seq_region_name_old`)
) ENGINE=InnoDB AUTO_INCREMENT=67084914 DEFAULT CHARSET=latin1;
=end
=cut
