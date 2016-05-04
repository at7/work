use strict;
use warnings;

use Bio::EnsEMBL::Registry;
my $registry = 'Bio::EnsEMBL::Registry';

#$registry->load_registry_from_db(
#  -host => 'ensembldb.ensembl.org',
#  -user => 'anonymous'
#);
$registry->load_registry_from_db(
  -host => 'mysql-eg-publicsql.ebi.ac.uk',
  -port => 4157
);


#my $species = 'human';
my $species = 'oryza_sativa';


my $va = $registry->get_adaptor($species, 'variation', 'Variation');


my $variation = $va->fetch_by_name('TBGI000707');


my $pgts = $variation->get_all_PopulationGenotypes;
 
foreach my $pop_gt_obj ( sort { $a->subsnp cmp $b->subsnp} @{ $pgts } ) {
  my $pop_obj = $pop_gt_obj->population;
  my $name = $pop_obj->name;
  my $frequency = $pop_gt_obj->frequency;
  my $count = $pop_gt_obj->count;
  my $genotype = $pop_gt_obj->genotype_string(1);
  print "$name $frequency $count $genotype\n";

}

