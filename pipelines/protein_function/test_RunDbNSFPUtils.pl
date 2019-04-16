use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Variation::Utils::RunDbNSFPUtils;

my $registry_file = '/hps/nobackup2/production/ensembl/anja/release_97/human/development/ensembl.registry';


my $dbNSFP = Bio::EnsEMBL::Variation::Utils::RunDbNSFPUtils->new(
  -registry_file => $registry_file,
  -species => 'Homo_sapiens',
  -working_dir => '/hps/nobackup2/production/ensembl/anja/release_97/human/development/',
  -dbnsfp_file => '/nfs/production/panda/ensembl/variation/data/dbNSFP/3.5a/dbNSFP3.5a.txt.gz',
  -assembly => 'GRCh38',
  -dbnsfp_version => '3.5a',
  -pipeline_mode => 0,
  -debug_mode => 1,
);

my $md5 = '0030eb92b95e5ef221b68237913c10fd';
my $translation_stable_id = 'ENSP00000380254';
$dbNSFP->run($translation_stable_id);

