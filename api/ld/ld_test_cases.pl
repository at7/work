use strict;
use warnings;
use Bio::EnsEMBL::Registry;

use FileHandle;
my $start_run = time();

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -port => 3337,
#  -db_version => 88,
);

#my $registry_file = 'ensembl.registry';
my $species = 'human';

#$registry->load_all($registry_file);

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

my $dir = '/hps/nobackup/production/ensembl/anja/release_89/ld/new_code/';

my $population_adaptor = $vdba->get_PopulationAdaptor;
my $population = $population_adaptor->fetch_by_name("1000GENOMES:phase_3:CEU");
my $variation_adaptor = $vdba->get_VariationAdaptor;
my $slice_adaptor = $cdba->get_SliceAdaptor;
my $ldFeatureContainerAdaptor = $vdba->get_LDFeatureContainerAdaptor;
$ldFeatureContainerAdaptor->db->use_vcf(1);

my $populations = {
  CLM => '1000GENOMES:phase_3:CLM',
  KHV => '1000GENOMES:phase_3:KHV',
  ITU => '1000GENOMES:phase_3:ITU',
  GWD => '1000GENOMES:phase_3:GWD'
};

my $pairwise = 0;

if ($pairwise) {
my @pairs = ('rs1925840_rs978750', 'rs34427641_rs61952472', 'rs10937411_rs16864809');


foreach my $pair (@pairs) {
  my @vfs = ();
  foreach my $name (split /_/, $pair) {
    my $variation = $variation_adaptor->fetch_by_name($name);
    my $vf = $variation->get_all_VariationFeatures()->[0];
    push @vfs, $vf;
  }

  foreach my $short_name (keys %$populations) {

    my $fh = FileHandle->new("$dir/pairwise/$short_name\_$pair.txt", 'w');

    my $long_name = $populations->{$short_name};
    my $population = $population_adaptor->fetch_by_name($long_name);    
    my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_VariationFeatures(\@vfs, $population);
    foreach my $r_square ( sort {$a->{r2} <=> $b->{r2} || $a->{variation2}->variation_name cmp $b->{variation2}->variation_name}    @{$ldFeatureContainer->get_all_r_square_values}){
      print $fh join("\t", $r_square->{r2}, $r_square->{variation1}->variation_name, $r_square->{variation2}->variation_name), "\n";
    }
    foreach my $d_prime ( sort {$a->{d_prime} <=> $b->{d_prime} || $a->{variation2}->variation_name cmp $b->{variation2}->variation_name}    @{$ldFeatureContainer->get_all_d_prime_values}){
      print $fh join("\t", $d_prime->{d_prime}, $d_prime->{variation1}->variation_name, $d_prime->{variation2}->variation_name), "\n";
    }

    $fh->close;
  }

}

}


my $by_region = 0;
my @regions = ('19_11400000_11500000', '13_36800000_36900000', '3_179200000_179300000');

if ($by_region) {
  foreach my $short_name (keys %$populations) {
    my $long_name = $populations->{$short_name};
    my $population = $population_adaptor->fetch_by_name($long_name);    
    foreach my $region (@regions) {
      my ($chrom, $start, $end) = split /_/, $region;
      my $slice = $slice_adaptor->fetch_by_region('chromosome', $chrom, $start, $end);

      my $fh = FileHandle->new("$dir/by_region/$short_name\_$region.txt", 'w');
      my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_Slice($slice, $population);
      print "$short_name $region ", scalar @{$ldFeatureContainer->get_all_r_square_values}, "\n";
#      foreach my $pair (@{$ldFeatureContainer->get_all_r_square_values}) {
#        print $pair->{variation1}->variation_name, "\n";
#        print $pair->{variation2}->variation_name, "\n";
#        print $pair->{r2}, "\n";
#      }
      foreach my $r_square ( sort {$a->{r2} <=> $b->{r2} || $a->{variation2}->variation_name cmp $b->{variation2}->variation_name}    @{$ldFeatureContainer->get_all_r_square_values}){
        print $fh join("\t", $r_square->{r2}, $r_square->{variation1}->variation_name, $r_square->{variation2}->variation_name), "\n";
      }
      foreach my $d_prime ( sort {$a->{d_prime} <=> $b->{d_prime} || $a->{variation2}->variation_name cmp $b->{variation2}->variation_name}    @{$ldFeatureContainer->get_all_d_prime_values}){
        print $fh join("\t", $d_prime->{d_prime}, $d_prime->{variation1}->variation_name, $d_prime->{variation2}->variation_name), "\n";
      }
      $fh->close;
    }
  }
}




my $by_variant = 1;
if ($by_variant) {
#foreach my $window (100, 200, 500, 1000) {
foreach my $window (200) {


  $ldFeatureContainerAdaptor->max_snp_distance(($window / 2) * 1000);

#  foreach my $name (qw/rs10937411 rs7349069 rs11585711/) {
  foreach my $name (qw/rs10937411/) {

    my $fh = FileHandle->new("$dir/$name\_$window.txt", 'w');
    my $variation = $variation_adaptor->fetch_by_name($name);
    my $vf = $variation->get_all_VariationFeatures()->[0];
    my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_VariationFeature($vf, $population);
    print STDERR "$window $name\n";
    foreach my $r_square ( sort {$a->{r2} <=> $b->{r2} || $a->{variation2}->variation_name cmp $b->{variation2}->variation_name}    @{$ldFeatureContainer->get_all_r_square_values}){
      print $fh join("\t", $r_square->{r2}, $r_square->{variation1}->variation_name, $r_square->{variation2}->variation_name), "\n";
    }
    foreach my $d_prime ( sort {$a->{d_prime} <=> $b->{d_prime} || $a->{variation2}->variation_name cmp $b->{variation2}->variation_name}    @{$ldFeatureContainer->get_all_d_prime_values}){
      print $fh join("\t", $d_prime->{d_prime}, $d_prime->{variation1}->variation_name, $d_prime->{variation2}->variation_name), "\n";
    }

    $fh->close;
    print scalar @{$ldFeatureContainer->get_all_r_square_values}, "\n";

  }

}
}

my $end_run = time();
my $run_time = $end_run - $start_run;
print STDERR "run time $run_time\n";

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
