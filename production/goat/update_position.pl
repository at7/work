use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup/production/ensembl/anja/release_92/goat/variation_qc/ensembl.registry');

my $dbh = $registry->get_DBAdaptor('goat', 'variation')->dbc->db_handle;
$dbh->do(qq{
  UPDATE vcf_variation_auch vcf, variation_synonym vs, variation_feature vf, seq_region sr
  SET vcf.variation_id = vf.variation_id, vcf.seq_region_name_new = sr.name, vcf.seq_region_start_new = vf.seq_region_start, vcf.allele_string_new = vf.allele_string
  WHERE vcf.subsnp_id = vs.name
  AND vs.variation_id = vf.variation_id
  AND vf.seq_region_id = sr.seq_region_id
  AND vf.display = 1;
}) or die $dbh->errstr;

