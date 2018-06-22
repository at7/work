use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Data::Dumper;
my $registry = 'Bio::EnsEMBL::Registry';


$registry->load_registry_from_db(
  -user => 'ensro',
  -host => 'mysql-ens-var-prod-1',
  -port => 4449,
);

my $species = 'capra_hircus';

my $va = $registry->get_adaptor($species, 'variation', 'variation');
my $vfa = $registry->get_adaptor($species, 'variation', 'variationfeature');
my $sgtfa = $registry->get_adaptor($species, 'variation', 'samplegenotypefeature');
my $pa = $registry->get_adaptor($species, 'variation', 'population'); 
my $ldfca = $registry->get_adaptor($species, 'variation', 'ldfeaturecontainer');

my $slice_adaptor = $registry->get_adaptor($species, 'core', 'slice');
my $variation = $va->fetch_by_name('rs268288050');
print $variation->name, "\n";

$va->db->use_vcf(1);
my $slice = $slice_adaptor->fetch_by_region('chromosome', 12, 500_000, 600_000);

my $vfs = $vfa->fetch_all_by_Slice($slice);
print 'Count VFS ', scalar @$vfs, "\n";
# VCFCollection::get_all_SampleGenotypeFeatures_by_Slice
my $sgts = $sgtfa->fetch_all_by_Slice($slice);
print 'Count SGTFS ', scalar @$vfs, "\n";

# LD


my $population_name = 'NextGen:MOCH';
my $population = $pa->fetch_by_name($population_name);


$variation = $va->fetch_by_name('rs668414674');
my $vf = $variation->get_all_VariationFeatures->[0];

#my $ldfc = $ldfca->fetch_by_Slice($slice, $population);
#my $ldfc = $ldfca->fetch_by_VariationFeature($vf, $population);

my @vfs = ();
#foreach my $name (qw/rs658196547 rs647909036 rs646273559 rs661132708 rs669371877 rs656077121 rs655080484 rs669694727 rs668414674/) {

foreach my $name (qw/rs658196547 rs647909036 rs668414674/) {
  my $variation = $va->fetch_by_name($name);
  my $vf = $variation->get_all_VariationFeatures->[0];
  push @vfs, $vf;
}


my $ldfc = $ldfca->fetch_by_VariationFeatures(\@vfs, $population);


foreach my $ld_hash (@{$ldfc->get_all_ld_values(0)}) {
    my $d_prime = $ld_hash->{d_prime};
    my $r2 = $ld_hash->{r2};
    my $variation1 = $ld_hash->{variation_name1};
    my $variation2 = $ld_hash->{variation_name2};
    my $vf1 = $ld_hash->{variation1};
    my $vf2 = $ld_hash->{variation2};
    my $vf1_name = $vf1->variation_name;
    my $vf2_name = $vf2->variation_name;
    my $vf1_start = $vf1->seq_region_start;
    my $vf1_end = $vf1->seq_region_end;
    my $vf1_seq_region_name = $vf1->seq_region_name;
    my $vf1_location = "$vf1_seq_region_name:$vf1_start";
    $vf1_location .= "-$vf1_end" if ($vf1_start != $vf1_end);
    my $vf1_consequence = $vf1->display_consequence; 
    my $vf1_evidence = join(',', @{$vf1->get_all_evidence_values});
    my $vf2_start = $vf2->seq_region_start;
    my $vf2_end = $vf2->seq_region_start;
    my $vf2_seq_region_name = $vf2->seq_region_name;
    my $vf2_location = "$vf2_seq_region_name:$vf2_start";
    $vf2_location .= "-$vf2_end" if ($vf2_start != $vf2_end);
    my $vf2_consequence = $vf2->display_consequence;
    my $vf2_evidence = join(',', @{$vf2->get_all_evidence_values});
    print STDERR join("\t", $vf1_name, $variation1, $vf1_location, $vf1_consequence, $vf1_evidence, $vf2_name, $variation2, $vf2_location, $vf2_consequence, $vf2_evidence, $r2, $d_prime), "\n";
#   print STDERR join("\t", $vf1_name, $variation1, $vf1_location, $vf1_consequence, $vf1_evidence, $vf2_name, $variation2, $vf2_location, $vf2_consequence, $vf2_evidence, $r2, $d_prime, $population_name), "\n";
#   print STDERR join("\t", $d_prime, $r2, $variation1, $variation2), "\n"; 
}


