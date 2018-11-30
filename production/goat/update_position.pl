use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;

my $registry = 'Bio::EnsEMBL::Registry';
#$registry->load_all('/hps/nobackup/production/ensembl/anja/release_92/goat/variation_qc/ensembl.registry');
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_95/cow/remapping_vcf/ensembl.registry.newasm');


my $dbh = $registry->get_DBAdaptor('cow', 'variation')->dbc->db_handle;

# first update variation_id
#
#$dbh->do(qq{
#  UPDATE vcf_variation vcf, bos_taurus_variation_94_31.variation_feature vf
#  SET vcf.variation_id = vf.variation_id
#  WHERE vcf.seq_region_id_old = vf.seq_region_id
#  AND vcf.seq_region_start_old = vf.seq_region_start;
#}) or die $dbh->errstr;


# first update new seq_region information
#
$dbh->do(qq{
  UPDATE vcf_variation vcf, variation_feature vf, seq_region sr
  SET vcf.seq_region_name_new = sr.name, vcf.seq_region_id_new = vf.seq_region_id, vcf.seq_region_start_new = vf.seq_region_start, vcf.allele_string_new = vf.allele_string
  WHERE vcf.variation_id = vf.variation_id
  AND vf.seq_region_id = sr.seq_region_id;
}) or die $dbh->errstr;


=begin
$dbh->do(qq{
  UPDATE vcf_variation_auch vcf, variation_synonym vs, variation_feature vf, seq_region sr
  SET vcf.variation_id = vf.variation_id, vcf.seq_region_name_new = sr.name, vcf.seq_region_start_new = vf.seq_region_start, vcf.allele_string_new = vf.allele_string
  WHERE vcf.subsnp_id = vs.name
  AND vs.variation_id = vf.variation_id
  AND vf.seq_region_id = sr.seq_region_id
  AND vf.display = 1;
}) or die $dbh->errstr;
=end
=cut
