use strict;
use warnings;

use Bio::EnsEMBL::Registry;

use FileHandle;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Sequence qw(reverse_comp expand);

my $species = 'gibbon';
my $registry_file = '/hps/nobackup/production/ensembl/anja/release_91/gibbon/remapping/ensembl.registry.newasm';

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all($registry_file);
my $vdba = $registry->get_DBAdaptor($species, 'variation');

my $dbh = $vdba->dbc->db_handle;

my $sth = $dbh->prepare(qq{
SELECT v.variation_id
FROM variation v
LEFT JOIN variation_feature vf ON v.variation_id = vf.variation_id
WHERE vf.variation_id IS NULL;
}, {mysql_use_result => 1});
$sth->execute();
while (my $row = $sth->fetchrow_arrayref) {
  my $variation_id = $row->[0];
  print STDERR $variation_id, "\n";
}
$sth->finish();


