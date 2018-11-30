use strict;
use warnings;

use Bio::EnsEMBL::Registry;


my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_95/cow/remapping_vcf/ensembl.registry.oldasm');

my $dbc = $registry->get_DBAdaptor('cow', 'variation')->dbc;
print $dbc->dbname, "\n";
