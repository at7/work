use strict;
use warnings;
use Bio::EnsEMBL::Registry;
use FileHandle;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'mysql-ens-var-prod-2',
  -user => 'ensro',
  -port => 4521,
  -db_version => 95,
);

my $species = 'cow';

my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/horse/compare_gts/cow_95', 'w');

my $va = $registry->get_adaptor($species, 'variation', 'Variation');
my $vfa = $registry->get_adaptor($species, 'variation', 'VariationFeature');
my $pa = $registry->get_adaptor($species, 'variation', 'Population');
my $population = $pa->fetch_by_name('NextGen:IRBT');
die unless ($population);
my $slice_adaptor = $registry->get_adaptor($species, 'core', 'Slice');
$va->db->use_vcf(1);
$va->db->vcf_config_file('/homes/anja/bin/ensembl-variation/modules/Bio/EnsEMBL/Variation/DBSQL/vcf_config_95.json');

#my $slice = $slice_adaptor->fetch_by_region('primary_assembly', 3);
my $slice = $slice_adaptor->fetch_by_region('primary_assembly', 3, 1, 1_000_000, 1);

my $vfs = $vfa->fetch_all_by_Slice($slice);

foreach my $vf (@$vfs) {
  my $variation = $vf->variation;
  my $allele_string = $vf->allele_string;
  my $variation_name = $variation->name;
  my $pgts = $variation->get_all_PopulationGenotypes($population);
  foreach my $pop_gt_obj (@$pgts) {
    my $pop_obj = $pop_gt_obj->population;
    my $name = $pop_obj->name;
    my $frequency = sprintf("%.4f", $pop_gt_obj->frequency);
    my $count = $pop_gt_obj->count;
    my $genotype = $pop_gt_obj->genotype_string(1);
    print $fh "$variation_name $allele_string $frequency $count $genotype\n";
  }
}

$fh->close;

