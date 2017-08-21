use strict;
$|=1;
use IPC::Run;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::ApiVersion; 
printf( "The API version used is %s\n", software_version() ); 

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all();
$registry->set_reconnect_when_lost(1);
$registry->load_registry_from_db(
   -host => 'useastdb.ensembl.org', # alternatively ensembldb 'useastdb.ensembl.org'
   -user => 'anonymous'
   );

my $LD_BASE_RADIUS = 100000;
my $chrom = "11";

my $var1 = "rs56391266";
my $region_start1 = "60376622";
my $region_end1 = "60376623";
my $var2 = "rs11291652";
my $region_start2 = "60360531";
my $region_end2 = "60360531";


my $pop_adaptor = $registry->get_adaptor("human","variation","population");
$pop_adaptor->db->use_vcf(1);
my $ldFeatureContainerAdaptor = $registry->get_adaptor('human', 'variation', 'ldfeaturecontainer'); #get adaptor for LDFeatureContainer object
$ldFeatureContainerAdaptor->db->use_vcf(1);
$ldFeatureContainerAdaptor->max_snp_distance($LD_BASE_RADIUS);

my $variation_adaptor = $registry->get_adaptor( 'human', 'variation', 'variation' );
$variation_adaptor->db->use_vcf(1);
  
my $population_name = "1000GENOMES:phase_3:EUR";
my $population = $pop_adaptor->fetch_by_name($population_name); #get population object from database

my $variation1 = $variation_adaptor->fetch_by_name("$var1");
my $vfref1 = $variation1->get_all_VariationFeatures();
my $query_variation_feature1;
my $found=0;
foreach my $vf1 (@{$vfref1}) {
   if ($chrom eq $vf1->seq_region_name) {
  if ($region_start1 eq $vf1->seq_region_start && $region_end1 eq $vf1->seq_region_end) {
      $found=1;
      $query_variation_feature1 = $vf1;
  }
   }
}
if ($found==0) {die;}

my $variation2 = $variation_adaptor->fetch_by_name("$var2");
my $vfref2 = $variation2->get_all_VariationFeatures();
my $query_variation_feature2;
$found=0;
foreach my $vf2 (@{$vfref2}) {
   if ($chrom eq $vf2->seq_region_name) {
  if ($region_start2 eq $vf2->seq_region_start && $region_end2 eq $vf2->seq_region_end) {
      $found=1;
      $query_variation_feature2 = $vf2;
  }
   }
}
if ($found==0) {die;}

my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_VariationFeatures([$query_variation_feature1, $query_variation_feature2],$population); #retrieve all LD values in the region

foreach my $r_square (@{$ldFeatureContainer->get_all_r_square_values}){
   if ($r_square->{r2} >= 0.1){ 
  print "variant 1: ".$r_square->{variation1}->variation_name." ".$r_square->{variation1}->seq_region_start." ".$r_square->{variation1}->seq_region_end."\n";
  print "variant 2: ".$r_square->{variation2}->variation_name." ".$r_square->{variation2}->seq_region_start." ".$r_square->{variation2}->seq_region_end."\n";
  print "r^2 ".$r_square->{r2}."\n";
   }
}

