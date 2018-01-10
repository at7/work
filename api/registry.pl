use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';


 $registry->load_registry_from_db(
    -host => 'mysql-ensembl-mirror.ebi.ac.uk',
    -port => 4240,
    -user => 'anonymous',
  );

my $va = $registry->get_adaptor('human', 'variation', 'variation');

my $variation = $va->fetch_by_name('rs699');

print $variation, "\n";
