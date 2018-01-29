use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::Registry;
use Data::Dumper;
my $registry = 'Bio::EnsEMBL::Registry';


$registry->load_all('/hps/nobackup/production/ensembl/anja/release_92/sheep/ensembl.registry');
my $species = 'sheep';
my $slice_adaptor = $registry->get_adaptor($species, 'core', 'slice');
# chromosome 12 length 79100223

my $slice = $slice_adaptor->fetch_by_region('chromosome', 12, 8_100_223, 9_100_223);
my $sample_genotype_feature_adaptor = $registry->get_adaptor($species, 'variation', 'samplegenotypefeature'); 
my $vca = $registry->get_adaptor($species, 'variation', 'vcfcollection');
$sample_genotype_feature_adaptor->db->use_vcf(1);
my $sample_adaptor = $registry->get_adaptor($species, 'variation', 'sample');
my $population_adaptor = $registry->get_adaptor($species, 'variation', 'population');
my $vfa = $registry->get_adaptor($species, 'variation', 'variationfeature');

my $c = $vca->fetch_by_id('sheep_genome_consortium');

my $population = $population_adaptor->fetch_by_name('ISGC:COMPOSITE');
my $samples = $sample_adaptor->fetch_all_by_name('ISGC:NZCMPM100017184841');
my $vfs = $c->get_all_SampleGenotypeFeatures_by_Slice($slice, $samples->[0]);
my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/sheep/ISGC_COMPOSITE', 'w'); 
foreach my $vf (@$vfs) {
  my $name = $vf->variation_feature->variation_name;
  my $genotype = $vf->genotype_string;
  print $fh "$name $genotype\n"; 
}
$fh->close;

