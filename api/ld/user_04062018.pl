use strict;
$|=1;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::ApiVersion;
printf( "The API version used is %s\n", software_version() );

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all();
$registry->load_registry_from_db(
   -host => 'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
   -user => 'anonymous',
   );

$registry->set_reconnect_when_lost(1);
my $v_adaptor = $registry->get_adaptor('homo_sapiens', 'variation', 'variation');
$v_adaptor->db->use_vcf(1);
my $slice_adaptor = $registry->get_adaptor('homo_sapiens', 'core', 'slice');
my $slice = $slice_adaptor->fetch_by_region('chromosome', 17, 46048119, 46248119);
my $pop_adaptor = $registry->get_adaptor("human","variation","population");
my $ldFeatureContainerAdaptor = $registry->get_adaptor('human', 'variation', 'ldfeaturecontainer');
$ldFeatureContainerAdaptor->max_snp_distance(100000);
my $population = $pop_adaptor->fetch_by_name("1000GENOMES:phase_3:CEU");
my $variation = $v_adaptor->fetch_by_name("rs1406071");
my $vfref = $variation->get_all_VariationFeatures();
my $query_variation_feature;
print "variation-feature chromosomes:\n";
foreach my $vf (@{$vfref}) {
   print "\t".$vf->seq_region_name."\n";
   if ($vf->seq_region_name eq "17") {
       $query_variation_feature = $vf;
   }
}
print "allele frequencies:\n";
my $alleles = $query_variation_feature->variation->get_all_Alleles();
foreach my $allele (@{$alleles}) {
   next unless (defined $allele->population);
   my $allele_string   = $allele->allele;
   my $frequency       = $allele->frequency || 'NA';
   my $population_name = $allele->population->name;
   if ($population_name=~/EUR/ && $population_name=~/1000/) {
       printf("\tAllele %s has frequency: %s in population %s.\n", $allele_string, $frequency, $population_name);
   }
}
my $variant_sets = $query_variation_feature->get_all_VariationSets();
print "variant sets:\n";
if (defined $variant_sets) {
   foreach my $vs (@{$variant_sets}){
       if ($vs->name()=~/EUR/) {
           print "\t".$vs->name()."\n";
       }
   }
}
print "LD results >= r2 0.99:\n";
my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_VariationFeature($query_variation_feature,$population);
#my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_Slice($slice,$population);

foreach my $r_square (@{$ldFeatureContainer->get_all_r_square_values}){
#   if ($r_square->{r2} >= 0.99){
       print "\t".$r_square->{variation1}->variation_name." ".$r_square->{variation2}->variation_name." ".$r_square->{r2}."\n";
#   }
}

