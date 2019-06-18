use strict;
use warnings;

use FileHandle;
use ImportUtils qw(load);
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
my $registry_file = '/hps/nobackup2/production/ensembl/anja/release_98/ancestral_alleles/ensembl.registry';
$registry->load_all($registry_file);
my $vdba = $registry->get_DBAdaptor('homo_sapiens', 'variation');
my $dbc = $vdba->dbc;

my $TMP_DIR = '/hps/nobackup2/production/ensembl/anja/release_98/ancestral_alleles/';
my $tmp_file = 'aa_new_dbsnp';

$ImportUtils::TMP_DIR  = $TMP_DIR;
$ImportUtils::TMP_FILE = $tmp_file;

$dbc->do(qq{
CREATE TABLE `variation_feature_id_AA` (
`variation_feature_id` int(10) unsigned NOT NULL DEFAULT '0',
`ancestral_allele` varchar(50) DEFAULT NULL,
UNIQUE KEY `vf_idx` (`variation_feature_id`));
}) or die $dbc->errstr;

load($dbc, qw(variation_feature_id_AA variation_feature_id ancestral_allele));

$dbc->do(qq{
  UPDATE variation_feature_id_AA vaa JOIN variation_feature v ON (vaa.variation_feature_id = v.variation_feature_id)
  SET v.ancestral_allele = vaa.ancestral_allele;
}) or die $dbc->errstr;
