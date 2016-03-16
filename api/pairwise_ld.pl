use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 83,
);

my $registry_file = 'ensembl.registry';
my $species = 'homo_sapiens';

$registry->load_all($registry_file);

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

my $population_adaptor = $vdba->get_PopulationAdaptor;
my $slice_adaptor = $cdba->get_SliceAdaptor;
my $ldFeatureContainerAdaptor = $vdba->get_LDFeatureContainerAdaptor;
$ldFeatureContainerAdaptor->db->use_vcf(1);
my $max_snp_distance = 500_000;
$ldFeatureContainerAdaptor->max_snp_distance($max_snp_distance);
my $va = $vdba->get_VariationAdaptor;
my $vfa = $vdba->get_VariationFeatureAdaptor;

my @vfs = ();

my $variant_name1 = 'rs2302417'; # rs2302417  rs6792369 
my $variant1 = $va->fetch_by_name($variant_name1);
my $vfs1 = $variant1->get_all_VariationFeatures;
print scalar @$vfs1, "\n";
push @vfs, @$vfs1;

my $variant_name2 = 'rs678';
my $variant2 = $va->fetch_by_name($variant_name2);
my $vfs2 = $variant2->get_all_VariationFeatures;
print scalar @$vfs2, "\n";
push @vfs, @$vfs2;

print scalar @vfs, "\n";

my @ld_populations = @{$population_adaptor->fetch_all_LD_Populations};

foreach my $ld_population (@ld_populations) {
  print $ld_population->name, "\n";
  my @ld_values = @{$ldFeatureContainerAdaptor->fetch_by_VariationFeatures(\@vfs, $ld_population)->get_all_ld_values(1)};
  foreach my $hash (@ld_values) {
    my $variation1 = $hash->{variation_name1};
    my $variation2 = $hash->{variation_name2};
    my $r2 = $hash->{r2};
    my $d_prime = $hash->{d_prime};
    my $population_id = $hash->{population_id};
    print "$variation1 $variation2 $r2 $d_prime $population_id\n";
  }
}

