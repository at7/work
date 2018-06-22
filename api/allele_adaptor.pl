use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous',
    -DB_VERSION => 92,
);

my $allele_adaptor = $registry->get_adaptor('human', 'variation', 'allele');
my $variation_adaptor = $registry->get_adaptor('human', 'variation', 'variation');
my $population_adaptor = $registry->get_adaptor('human', 'variation', 'population');


$variation_adaptor->db->use_vcf(1);
my $variation = $variation_adaptor->fetch_by_name('rs79022493');
#my $population = $population_adaptor->fetch_by_name('gnomADg:AMR');
my $population = $population_adaptor->fetch_by_name('1000GENOMES:phase_3:ESN');


#print $population->dbID, "\n";

my $alleles = $allele_adaptor->fetch_all_by_Variation($variation, $population);
#my $alleles = $allele_adaptor->fetch_all_by_Variation($variation, 'gnomADg:AMR');


print scalar @$alleles, "\n";

foreach my $allele (@$alleles) {
  my $allele_string = $allele->allele;
  my $frequency = $allele->frequency;
  my $population_object = $allele->population;
  my $population_name = 'NA';
  if ($population_object) {
    $population_name = $population_object->name;
  }
  print "$allele_string $frequency $population_name\n";
}
