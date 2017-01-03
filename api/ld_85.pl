use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';


$registry->load_all('/lustre/scratch110/ensembl/at7/release_85/human/ensembl.registry');

#$reg->load_registry_from_db(
#  -host => 'ensembldb.ensembl.org',
#  -user => 'anonymous',
#);


my $variation_adaptor = $registry->get_adaptor('human', 'variation', 'variation');
my $ldfc_adaptor = $registry->get_adaptor('human', 'variation', 'ldfeaturecontainer');
my $pop_adaptor = $registry->get_adaptor('human', 'variation', 'population');
$variation_adaptor->db->use_vcf(1);

my $ld_population = $pop_adaptor->fetch_by_name('1000GENOMES:phase_3:PEL');


# Loop through all SNPs available and find SNPs in LD
my $variation_name = 'rs6820980';
my $variation = $variation_adaptor->fetch_by_name($variation_name);
my @var_features = @{ $variation->get_all_VariationFeatures() };

print scalar @var_features, "\n";


foreach my $vf (@var_features) {
  my $ldfc = $ldfc_adaptor->fetch_by_VariationFeature($vf, $ld_population);
  my $ld_values = $ldfc->get_all_ld_values;
}


=begin
my @var_features;

if ($variation) {
@var_features = @{ $variation->get_all_VariationFeatures() };
} else {
print 'failing variation name: ', $variation_name, "\n";
next;
}


foreach my $vf (@var_features) {
  my $rsid = $vf->name;
  print $rsid, "\n";
  my $start = $vf->start;
  my $region = $vf->seq_region_name;
  print "$region\t$rsid\t$start\n";
  my $ldfc = $ldfc_adaptor->fetch_by_VariationFeature($vf, $ld_population);
}
=end
=cut
