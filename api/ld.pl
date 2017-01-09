use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';


$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
#  -db_version => 83,
);

my $registry_file = 'ensembl.registry';
my $species = 'homo_sapiens';

$registry->load_all($registry_file);

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

my $population_adaptor = $vdba->get_PopulationAdaptor;
my $variation_adaptor = $vdba->get_VariationAdaptor;
my $slice_adaptor = $cdba->get_SliceAdaptor;
my $ldFeatureContainerAdaptor = $vdba->get_LDFeatureContainerAdaptor;
$ldFeatureContainerAdaptor->db->use_vcf(1);

my $var1 = $variation_adaptor->fetch_by_name('rs7681154');
print scalar @{$var1->get_all_VariationFeatures}, "\n";
my $vf1 = $var1->get_all_VariationFeatures->[0];
my $var2 = $variation_adaptor->fetch_by_name('rs2583983');
print scalar @{$var2->get_all_VariationFeatures}, "\n";
my $vf2 = $var2->get_all_VariationFeatures->[0];

my $population_name = '1000GENOMES:phase_3:EUR'; #we only want LD in this population
my $population = $population_adaptor->fetch_by_name($population_name); #get population object from database

#$ldFeatureContainerAdaptor->fetch_by_VariationFeatures([$vf1, $vf2], $population);

my @ld_values = @{$ldFeatureContainerAdaptor->fetch_by_VariationFeatures([$vf1, $vf2], $population)->get_all_ld_values()};

print $var1->name, "\n";
print $var2->name, "\n";

=begin
my $max_snp_distance = 800_000;
$ldFeatureContainerAdaptor->max_snp_distance($max_snp_distance);
my $variation_adaptor = $vdba->get_VariationAdaptor;
my $vfa = $vdba->get_VariationFeatureAdaptor;


#my $chr = 6;  #defining the region in chromosome 6
#my $start = 25_837_556;
#my $end = 25_843_455;
#my $chr = 7;
#my $start =  48_902_556;
#my $end = 48_903_891;
#my $variant_name = 'rs1042779';
my $variant_name = 'rs611646';

my $variant = $variation_adaptor->fetch_by_name($variant_name);
print $variant->name, "\n";
my $vfs = $variant->get_all_VariationFeatures;
my $vf = $vfs->[0];

my $population_name = '1000GENOMES:phase_3:EUR'; #we only want LD in this population
my $population = $population_adaptor->fetch_by_name($population_name); #get population object from database

#print "fetch_by_Slice use VCF\n";
#my $slice = $slice_adaptor->fetch_by_region('chromosome',$chr,$start,$end); #get slice of the region
#$ldFeatureContainerAdaptor->db->include_failed_variations(1);
#my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_Slice($slice);
#my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_Slice($slice, $population);

my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_VariationFeature($vf, $population);

print_container_content($ldFeatureContainer);

print "fetch_by_VariationFeatures use VCF\n";
#High LD between variations rs114473994-rs6904823
#my $v1 = $variation_adaptor->fetch_by_name('rs114473994'); # 6:25837546
#my $v2 = $variation_adaptor->fetch_by_name('rs6904823'); #   6:25843441
#my $v1 = $variation_adaptor->fetch_by_name('rs4977575');
#my $v2 = $variation_adaptor->fetch_by_name('rs1333050');

#my $vf1 = $v1->get_all_VariationFeatures->[0];
#my $vf2 = $v2->get_all_VariationFeatures->[0];

#$ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_VariationFeatures([$vf1, $vf2], $population);
#$ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_VariationFeatures([$vf1, $vf2]);


#print_container_content($ldFeatureContainer);

sub print_container_content {
  my $ldFeatureContainer = shift;
  print "Name ", $ldFeatureContainer->name, "\n";
  my @variations = @{$ldFeatureContainer->get_variations()};
  print "Variations: ", scalar @variations, "\n";
  my @ld_values = @{$ldFeatureContainer->get_all_ld_values}; 
  print "LD values: ", scalar @ld_values, "\n"; 
  my @r_square_values = @{$ldFeatureContainer->get_all_r_square_values}; 
  print "R square values: ", scalar @r_square_values, "\n";
  my @d_prime_values = @{$ldFeatureContainer->get_all_d_prime_values};
  print "D prime values: ", scalar @d_prime_values, "\n"; 
  my $count = count_ld_values($ldFeatureContainer);
  print "LD count $count\n";
}

sub count_ld_values {
  my $container = shift;
  my $ld_values = 0;
  foreach my $key (keys %{$container->{'ldContainer'}}) {
    $ld_values += keys %{$container->{'ldContainer'}->{$key}};
  }
  return $ld_values;
}
=end
=cut
