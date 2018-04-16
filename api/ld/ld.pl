use strict;
use warnings;
use Bio::EnsEMBL::Registry;

use G2P::Registry;
use Getopt::Long;
use FileHandle;
use Bio::EnsEMBL::Utils::Slice qw(split_Slices);

my $config = {};
GetOptions(
  $config,
  'registry_file=s',
  'analysis=s',
  'population=s',
) or die "Error: Failed to parse command line arguments\n";

# analysis: region, pairwise, 

my $species = 'homo_sapiens';

my $registry = 'Bio::EnsEMBL::Registry';

if ($config->{registry_file}) {
  $registry->load_all($config->{registry_file});
} else {
  $registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous',
  );
}

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

my $population_adaptor = $vdba->get_PopulationAdaptor;
my $variation_adaptor = $vdba->get_VariationAdaptor;
my $slice_adaptor = $cdba->get_SliceAdaptor;
$variation_adaptor->db->use_vcf(1);

my $population = $population_adaptor->fetch_by_name('1000GENOMES:phase_3:GBR');

my $test_data = {
  variants => [''],
  populations => [],

};

print_use_case_cmds();

sub print_use_case_cmds {
  # region170,805,979 
#  my $slice = $slice_adaptor->fetch_by_region('chromosome', 6, 26_547_595, 28_548_492);
  my $slice = $slice_adaptor->fetch_by_region('chromosome', 6, 26_547_595, 36_547_595);

  my $ldFeatureContainerAdaptor = $vdba->get_LDFeatureContainerAdaptor;
  my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_Slice($slice, $population);

#  my $v1 = $variation_adaptor->fetch_by_name('rs726830');
#  my $vf1 = $v1->get_all_VariationFeatures->[0];
#  my $v2 = $variation_adaptor->fetch_by_name('rs71546548');
#  my $vf2 = $v2->get_all_VariationFeatures->[0];
#  $ldFeatureContainerAdaptor->fetch_by_VariationFeatures([$vf1, $vf2], $population);



}

# split chromosome into 1MB slices and compute LD for each region
sub comput_ld_chromosome {
  my $max_split_slice_length = 1_000_000;
  my $overlap = 500_000;

  my $slice = $slice_adaptor->fetch_by_region('chromosome', 6);
  my $slice_pieces = split_Slices([$slice], $max_split_slice_length, $overlap);

  foreach my $slice_piece (@$slice_pieces) {
    my $chr = $slice_piece->seq_region_name;
    my $start = $slice_piece->seq_region_start;
    my $end = $slice_piece->seq_region_end;  
    my $ldFeatureContainerAdaptor = $vdba->get_LDFeatureContainerAdaptor;
    my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_Slice($slice_piece, $population);
    print_container_content($ldFeatureContainer, "/hps/nobackup/production/ensembl/anja/ld/GBR_$chr\_$start\_$end.txt");
  }
}

sub print_container_content {
  my $ldFeatureContainer = shift;
  my $file_name = shift;
  my $no_vf_attribs = 1;
  my $fh = FileHandle->new($file_name, 'w');
  foreach my $ld_hash (@{$ldFeatureContainer->get_all_ld_values($no_vf_attribs)}) {
    my $d_prime = $ld_hash->{d_prime};
    my $r2 = $ld_hash->{r2};
    my $variation1 = $ld_hash->{variation_name1}; 
    my $variation2 = $ld_hash->{variation_name2}; 
    print $fh "$variation1 $variation2 $d_prime $r2\n";
  }
  $fh->close;
}


=begin
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
