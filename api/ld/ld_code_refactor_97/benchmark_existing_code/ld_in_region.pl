use strict;
use warnings;


use Bio::EnsEMBL::Registry;


my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'mysql-ens-mirror-1',
  -user => 'ensro',
  -port => 4240,
);

my @regions = qw//;
