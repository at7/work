use strict;
use warnings;

use Bio::EnsEMBL::Registry;
my $registry = 'Bio::EnsEMBL::Registry';

#$registry->load_registry_from_db(
#  -host => 'ensembldb.ensembl.org',
#  -user => 'anonymous'
#);

$registry->load_registry_from_db(
  -port => 4239,
  -user => 'ensro',
  -db_version => 84,
#  -database => 'oryza_sativa_variation_31_84_7',
);


#my $species = 'human';
my $species = 'oryza_sativa';


my $va = $registry->get_adaptor($species, 'variation', 'Variation');
my $pa = $registry->get_adaptor($species, 'variation', 'Population');

$va->db->use_vcf(2);
#$va->db->vcf_config_file('/nfs/production/panda/ensemblgenomes/development/dbolser/Web/Test_Ensembl_84/eg-web-plants/conf/json/Oryza_sativa_vcf.json');
#$va->db->vcf_config_file('/homes/anja/bin/work/api/Oryza_sativa_vcf.json');
#$va->db->vcf_root_dir();

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
