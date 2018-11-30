use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;

my $registry = 'Bio::EnsEMBL::Registry';
#$registry->load_all('/hps/nobackup/production/ensembl/anja/release_92/goat/variation_qc/ensembl.registry');
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_95/horse/remapping_vcf/ensembl.registry.newasm');


my $dbh = $registry->get_DBAdaptor('horse', 'variation')->dbc->db_handle;

$dbh->do(qq{
  UPDATE vcf_variation_irbt vcf, variation_feature vf, seq_region sr
  SET vcf.seq_region_name_new = sr.name, vcf.seq_region_start_new = vf.seq_region_start, vcf.allele_string_new = vf.allele_string
  WHERE vcf.variation_id = vf.variation_id
  AND vf.seq_region_id = sr.seq_region_id
  AND vf.display = 1;
}) or die $dbh->errstr;

=begin
$dbh->do(qq{
  UPDATE vcf_variation_irbt vcf, variation_feature vf, seq_region sr
  SET vcf.seq_region_name_new = sr.name, vcf.seq_region_start_new = vf.seq_region_start, vcf.allele_string_new = vf.allele_string
  WHERE vcf.variation_id = vf.variation_id
  AND vf.seq_region_id = sr.seq_region_id
  AND vf.display = 1;
}) or die $dbh->errstr;

$dbh->do(qq{
  UPDATE vcf_variation_auch vcf, variation_synonym vs, variation_feature vf, seq_region sr
  SET vcf.variation_id = vf.variation_id, vcf.seq_region_name_new = sr.name, vcf.seq_region_start_new = vf.seq_region_start, vcf.allele_string_new = vf.allele_string
  WHERE vcf.subsnp_id = vs.name
  AND vs.variation_id = vf.variation_id
  AND vf.seq_region_id = sr.seq_region_id
  AND vf.display = 1;
}) or die $dbh->errstr;

CREATE TABLE `vcf_variation` (
  `vcf_variation_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `seq_region_name_old` varchar(50) DEFAULT NULL,
  `seq_region_id` int(10) unsigned NOT NULL,
  `seq_region_start_old` int(11) DEFAULT NULL,
  `allele_string_old` varchar(50) DEFAULT NULL,
  `subsnp_id` int(10) unsigned DEFAULT NULL,
  `variation_id` int(10) unsigned DEFAULT NULL,
  `seq_region_name_new` varchar(50) DEFAULT NULL,
  `seq_region_start_new` int(11) DEFAULT NULL,
  `allele_string_new` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`vcf_variation_id`),
  KEY `variation_idx` (`variation_id`),
  KEY `subsnp_idx` (`subsnp_id`),
  KEY `seq_region_name_old_idx` (`seq_region_name_old`)
); 



=end
=cut
