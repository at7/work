use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

my $species = 'human';

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

my $population_adaptor = $vdba->get_PopulationAdaptor;
my $population = $population_adaptor->fetch_by_name("1000GENOMES:phase_3:KHV");
my $variation_adaptor = $vdba->get_VariationAdaptor;
my $ldFeatureContainerAdaptor = $vdba->get_LDFeatureContainerAdaptor;
#$ldFeatureContainerAdaptor->db->use_vcf(1);
#$ldFeatureContainerAdaptor->max_snp_distance(500_000);

my $var = $variation_adaptor->fetch_by_name('rs368234815');

my $sgts = $var->get_all_SampleGenotypes();

print scalar @$sgts, "\n";

#my $variation = $variation_adaptor->fetch_by_name('rs12445289');
#my $vf = $variation->get_all_VariationFeatures()->[0];
#my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_VariationFeature($vf, $population);

#print 'LD values ',  scalar @{$ldFeatureContainer->get_all_d_prime_values}, "\n";

#foreach my $d_prime (@{$ldFeatureContainer->get_all_d_prime_values}){
#    print "d_prime (".($d_prime->{d_prime}).") between variations ", $d_prime->{variation1}->variation_name, "-", $d_prime->{variation2}->variation_name, "\n";
#}

