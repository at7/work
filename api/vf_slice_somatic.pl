use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Slice qw(split_Slices);

my $registry = 'Bio::EnsEMBL::Registry';


$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -DB_VERSION => 91,
);

#@somatic_mutations = @{$vdb->get_VariationFeatureAdaptor->fetch_all_somatic_with_phenotype_by_Slice($slice, ) || []};
#@somatic_mutations = @{$slice->get_all_somatic_VariationFeatures_with_phenotype(undef, undef, $filter, $var_db) || []};


my $species = 'human';

my $slice_adaptor = $registry->get_adaptor($species, 'core', 'slice');
my $vfa = $registry->get_adaptor($species, 'variation', 'variationfeature');
my $slice = $slice_adaptor->fetch_by_region( 'chromosome', 14 );

my $filter = undef;
my $var_db = 'variation';
my @somatic_mutations = @{$slice->get_all_somatic_VariationFeatures_with_phenotype(undef, undef, $filter, $var_db) || []};

print STDERR scalar @somatic_mutations, "\n";

@somatic_mutations = @{$vfa->fetch_all_somatic_with_phenotype_by_Slice($slice) || []};

print STDERR scalar @somatic_mutations, "\n";
foreach my $mutation (@somatic_mutations) {
  print STDERR $mutation->seq_region_start, "\n";
}

