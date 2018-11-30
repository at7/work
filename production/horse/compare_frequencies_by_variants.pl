use strict;
use warnings;
use Bio::EnsEMBL::Registry;
use FileHandle;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'mysql-ensembl-mirror',
  -user => 'ensro',
  -port => 4240,
  -db_version => 94,
);

my $species = 'horse';

#my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/horse/compare_gts/horse_94', 'w');

my $va = $registry->get_adaptor($species, 'variation', 'Variation');
my $vfa = $registry->get_adaptor($species, 'variation', 'VariationFeature');
my $pa = $registry->get_adaptor($species, 'variation', 'Population');
my $slice_adaptor = $registry->get_adaptor($species, 'core', 'Slice');
$va->db->use_vcf(1);

my $variation = $va->fetch_by_name('rs394290687');

#my $slice = $slice_adaptor->fetch_by_region('chromosome', 3);

#my $vfs = $vfa->fetch_all_by_Slice($slice);

#foreach my $vf (@$vfs) {
  my $variation_name = $variation->name;
  my $pgts = $variation->get_all_PopulationGenotypes();
  my $alleles = $variation->get_all_Alleles();
  foreach my $allele (@$alleles) {
    print $allele->allele, ' ', $allele->population->name, ' ', $allele->frequency, "\n";
  }

  foreach my $pop_gt_obj (@$pgts) {
    my $pop_obj = $pop_gt_obj->population;
    my $name = $pop_obj->name;
    my $frequency = $pop_gt_obj->frequency;
    my $count = $pop_gt_obj->count;
    my $genotype = $pop_gt_obj->genotype_string(1);
    print  "$variation_name $name $frequency $count $genotype\n";
  }
#}

#$fh->close;

=begin
my $variation = $va->fetch_by_name('TBGI000707');
print $variation->name, "\n";
#my $variation = $va->fetch_by_name('rs1333049');

my $populations = $pa->fetch_all;


foreach my $population (@$populations) {
  print $population->name, "\n";
  my $pgts = $variation->get_all_PopulationGenotypes($population);

  #foreach my $pop_gt_obj ( sort { $a->subsnp cmp $b->subsnp} @{ $pgts } ) {
  foreach my $pop_gt_obj (@$pgts) {
    my $pop_obj = $pop_gt_obj->population;
    my $name = $pop_obj->name;
    my $frequency = $pop_gt_obj->frequency;
    my $count = $pop_gt_obj->count;
    my $genotype = $pop_gt_obj->genotype_string(1);
    print "$name $frequency $count $genotype\n";

  }
}
=end
=cut
