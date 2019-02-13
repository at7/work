use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use ImportUtils qw(load);
use Digest::MD5 qw(md5_hex);


my $id = 'ENSSSCG00000023500';

print md5_hex($id);

=begin
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_96/human/remap_gnomad/ensembl.registry');
my $vdba = $registry->get_DBAdaptor('human', 'variation');

$ImportUtils::TMP_DIR = $tmpdir;
$ImportUtils::TMP_FILE = $files->{$table}->{filename};
my $table = '';
my @columns = qw//;

load($vdba->dbc, ($table, @columns);
=end
=cut
