use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_95/horse/remapping_vcf/ensembl.registry.newasm');
my $dbc = $registry->get_DBAdaptor('horse', 'variation')->dbc;

  $dbc->do(qq{ DROP TABLE IF EXISTS vcf_variation}) or die $!;
 

  $dbc->do(qq{ 
    CREATE TABLE vcf_variation (
      vcf_variation_id int(10) unsigned NOT NULL AUTO_INCREMENT,
      seq_region_name_old varchar(50) DEFAULT NULL,
      seq_region_id_old int(10) unsigned DEFAULT NULL,
      seq_region_start_old int(11) DEFAULT NULL,
      seq_region_start_padded_old int(11) DEFAULT NULL,
      allele_string_old varchar(50) DEFAULT NULL,
      allele_string_padded_old varchar(50) DEFAULT NULL,
      vcf_id int(10) unsigned DEFAULT NULL,
      variation_id int(10) unsigned DEFAULT NULL,
      seq_region_name_new varchar(50) DEFAULT NULL,
      seq_region_id_new int(10) unsigned DEFAULT NULL,
      seq_region_start_new int(11) DEFAULT NULL,
      seq_region_start_padded_new int(11) DEFAULT NULL,
      allele_string_new varchar(50) DEFAULT NULL,
      allele_string_padded_new varchar(50) DEFAULT NULL,
      PRIMARY KEY (vcf_variation_id),
      KEY variation_idx (variation_id),
      KEY seq_region_name_old_idx (seq_region_name_old),
      KEY seq_region_id_old_idx (seq_region_id_old),
      KEY seq_region_start_old_idx (seq_region_start_old)
    );
  }) or die $!;

