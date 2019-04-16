use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -DB_VERSION => 95
);

my $population_adaptor = $registry->get_adaptor('human', 'variation', 'population');
my $variation_adaptor = $registry->get_adaptor('human', 'variation', 'variation');
my $vfa = $registry->get_adaptor('human', 'variation', 'variationfeature');
$variation_adaptor->db->use_vcf(1);

my $slice_adaptor = $registry->get_adaptor('human', 'core', 'slice');
#   133,797,422 
my $slice = $slice_adaptor->fetch_by_region('chromosome', 10, 33_797_422, 33_798_422);

my @vfs = @{$vfa->fetch_all_by_Slice($slice)};
foreach my $vf (@vfs) {
  
  my $variation = $vf->variation;
  my $variation_name = $variation->name;
  # 1
  my $alleles = $variation->get_all_Alleles();

  foreach my $allele (@$alleles) {
    my $allele_string = $allele->allele;
    my $population = $allele->population; 
    my $frequency = $allele->frequency;
    my $count = $allele->count || 'NA';
    if ($population && $frequency) {
      my $population_name = $population->name;
      if ($population_name =~ /gnomad/i) {
        print STDERR "$variation_name $allele_string $population_name $frequency $count\n";
      }
    }
  }
}
=begin
# 2
foreach my $allele (@$alleles) {
  my $allele_string = $allele->allele;
  my $population = $allele->population; 
  my $frequency = $allele->frequency;
  my $count = $allele->count || 'NA';
  if ($population && $frequency) {
    my $population_name = $population->name;
    if ($population_name =~ /1000GENOMES:phase_3:FIN|1000GENOMES:phase_3:CHB|1000GENOMES:phase_3:ASW/i) {
      print "$allele_string $population_name $frequency $count\n";
    }
  }
}
=begin
my $population = $population_adaptor->fetch_by_name('1000GENOMES:phase_3:ACB');

# 3
my $sample_genotypes = $variation->get_all_SampleGenotypes($population);
foreach my $sample_genotype(@$sample_genotypes) {
  my $sample_name = $sample_genotype->sample->name;
  my $genotype_string = $sample_genotype->genotype_string;
  if ($genotype_string eq 'A|G' || $genotype_string eq 'G|A') {
    print "$sample_name $genotype_string\n";
  }
}

# 4
my $population_genotypes = $variation->get_all_PopulationGenotypes($population);
foreach my $population_genotype (@$population_genotypes) {
  my $population_name = $population_genotype->population->name; 
  my $genotype_string = $population_genotype->genotype_string;
  my $frequency = $population_genotype->frequency;
  my $count = $population_genotype->count;
  print "$population_name $genotype_string $frequency $count\n";
}
=end
=cut
