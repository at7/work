use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous',
    -port => 3337,
);

my $variation_adaptor = $registry->get_adaptor(
  'human',  # species
  'variation',  # database
  'variation' # object type
);

$variation_adaptor->db->include_failed_variations(1);

my $variation = $variation_adaptor->fetch_by_name('rs79022493');




print $variation, "\n";
