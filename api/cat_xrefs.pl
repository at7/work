use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

#$registry->load_registry_from_db(
#  -host => 'mysql-ens-sta-1',
#  -user => 'ensro',
#  -port => 4519,
#);

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -DB_VERSION => 97,
);


my $vdba = $registry->get_DBAdaptor('cat', 'variation');
my $cdba = $registry->get_DBAdaptor('cat', 'core');

my $ga = $cdba->get_GeneAdaptor;

my $gene = $ga->fetch_by_stable_id('ENSFCAG00000026758');

my $gene_name = $gene->display_xref->display_id;

print $gene_name, "\n";
