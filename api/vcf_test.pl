use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

#$registry->load_registry_from_db(
#    -host => 'ensembldb.ensembl.org',
#    -user => 'anonymous',
#    -port => 3337
#);
my $file = '/hps/nobackup/production/ensembl/anja/release_88/human/ensembl.registry.88';

$registry->load_all($file);
my $variation_adaptor = $registry->get_adaptor('human', 'variation', 'variation');
my $population_adaptor = $registry->get_adaptor('human', 'variation', 'population');
$variation_adaptor->db->use_vcf(1);

my $variation = $variation_adaptor->fetch_by_name('rs1799964');
my $population = $population_adaptor->fetch_by_name('CSHL-HAPMAP:HAPMAP-CHD');
#my $population = $population_adaptor->fetch_by_name('1000GENOMES:phase_3:ACB');


my @alleles = @{$variation->get_all_Alleles($population)};
foreach my $allele (@alleles) {
  print $allele->allele, ' ', $allele->frequency, "\n";
}

my @pgts = @{$variation->get_all_PopulationGenotypes($population)};
foreach my $pgt (@pgts) {
  print $pgt->genotype_string, ' ', $pgt->frequency, "\n";
}

print scalar @alleles, "\n";
