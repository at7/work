use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Data::Dumper;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
-host => 'ensembldb.ensembl.org',
-user => 'anonymous',
-db_version => 84,
);

my $species = 'mus_musculus';
my $slice_adaptor = $registry->get_adaptor($species, 'core', 'slice');

my $sample_genotype_feature_adaptor = $registry->get_adaptor($species, 'variation', 'samplegenotypefeature'); 
$sample_genotype_feature_adaptor->db->use_vcf(1);

my $sample_adaptor = $registry->get_adaptor($species, 'variation', 'sample');
my $population_adaptor = $registry->get_adaptor($species, 'variation', 'population');

#my $populations = $population_adaptor->fetch_all();
#foreach my $population (@$populations) {
#  print $population->name, "\n";
#}

my $population = $population_adaptor->fetch_by_name('Mouse Genomes Project');
my $samples = $population->get_all_Samples;

my $chr = 1;
my $start = 3_574_805;
my $end = 3_674_845;
#my ($chr, $start, $end) = (1, 3_570_888, 3_570_950);
my $slice = $slice_adaptor->fetch_by_region('chromosome', $chr, $start, $end);

my $sgfs = $sample_genotype_feature_adaptor->fetch_all_by_Slice($slice);
print scalar @$sgfs, "\n";


#my $population = $population_adptor->fetch_by_name();
my $sample = $sample_adaptor->fetch_all_by_name('MGP:AKR/J')->[0];
print $sample->name, "\n";

my $unique_sgfs = $sample_genotype_feature_adaptor->fetch_all_unique_by_Slice($slice, $sample, $population);

print 'unique ', scalar @$unique_sgfs, "\n";

my $differences_sgfs = $sample_genotype_feature_adaptor->fetch_all_differences_by_Slice($slice, $sample, $population);
print 'differences ', scalar @$differences_sgfs, "\n";


