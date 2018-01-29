use strict;
use warnings;

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

#my $vfs = $vfa->fetch_all_by_Slice($slice);
#print scalar @$vfs, "\n";

# sheep_genome_project #
# nextgen_sheep_iroa
#my $vcf_collections = $vca->fetch_all;

my $c = $vca->fetch_by_id('sheep_genome_project');

#my $samples = $c->get_all_Samples;
#foreach my $sample (@$samples) {
#  print $sample->name, "\n";
#}
my $json =  `curl -H 'Content-Type:application/json' 'https://www.ebi.ac.uk/biosamples/api/samples/search/findByAccession?accession=ZAAWDU000000000001'`;

print STDERR $json, "\n";

#my $vfs = $c->get_all_SampleGenotypeFeatures_by_Slice($slice);
#print STDERR 'SampleGenotypeFeatures ', scalar @$vfs, "\n";

