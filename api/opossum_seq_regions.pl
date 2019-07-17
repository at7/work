use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'mysql-ens-sta-1',
  -user => 'ensro',
  -port => 4519,
);



my $cdba = $registry->get_DBAdaptor('opossum', 'core');

my $sa = $cdba->get_SliceAdaptor;
foreach my $slice (@{$sa->fetch_all('primary_assembly')}) {
  print $slice->seq_region_name, "\n" if $slice->is_toplevel;
}

