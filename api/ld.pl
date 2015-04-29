use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
);

my $chr = 6;  #defining the region in chromosome 6
my $start = 25_834_000;
my $end = 25_854_000;
my $population_name = 'CSHL-HAPMAP:HapMap-CEU'; #we only want LD in this population

my $slice_adaptor = $registry->get_adaptor('human', 'core', 'slice'); #get adaptor for Slice object
my $slice = $slice_adaptor->fetch_by_region('chromosome',$chr,$start,$end); #get slice of the region


my $population_adaptor = $registry->get_adaptor('human', 'variation', 'population'); #get adaptor for Population object
my $population = $population_adaptor->fetch_by_name($population_name); #get population object from database

my $ldFeatureContainerAdaptor = $registry->get_adaptor('human', 'variation', 'ldfeaturecontainer'); #get adaptor for LDFeatureContainer object
my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_Slice($slice,$population); #retrieve all LD values in the region

foreach my $r_square (@{$ldFeatureContainer->get_all_r_square_values}){
  if ($r_square->{r2} > 0.8){ #only print high LD, where high is defined as r2 > 0.8
    print "High LD between variations ", $r_square->{variation1}->variation_name,"-", $r_square->{variation2}->variation_name, "\n";
  }
}
