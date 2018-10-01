use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

my $va = $registry->get_adaptor('human', 'variation', 'variation');

$va->db->use_vcf(1);

my $variation = $va->fetch_by_name('rs2472297');

my $population_genotypes = $variation->get_all_PopulationGenotypes;

foreach my $pg (@$population_genotypes) {
  my $genotype = $pg->genotype_string;
  my $population_name = $pg->population->name;
  my $frequency = $pg->frequency;
  print "$population_name $genotype $frequency \n";
}
print scalar @$population_genotypes, "\n";

my $alleles = $variation->get_all_Alleles;
foreach my $allele (@$alleles) {
  my $population_name = $allele->population->name;
  my $allele_string = $allele->allele;
  my $frequency = $allele->frequency || 'NA';
  print "$population_name $allele_string $frequency\n";
}



