use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous',
    -port => 3337
);

my $variation_adaptor = $registry->get_adaptor('human', 'variation', 'variation');
my $population_adaptor = $registry->get_adaptor('human', 'variation', 'population');
$variation_adaptor->db->use_vcf(1);

my $variation = $variation_adaptor->fetch_by_name('rs1799964');
my $population = $population_adaptor->fetch_by_name('1000GENOMES:phase_3:AFR');

my @alleles = @{$variation->get_all_Alleles($population)};

print scalar @alleles, "\n";
