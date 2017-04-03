use strict;

use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';


$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

my $registry_file = 'ensembl.registry';
my $species = 'homo_sapiens';

$registry->load_all($registry_file);

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

my $slice_adaptor = $cdba->get_SliceAdaptor;
my $vfa = $vdba->get_VariationFeatureAdaptor;

my $slice = $slice_adaptor->fetch_by_region('chromosome', 6, 28960184, 29862000);

my $vfs = $vfa->fetch_all_by_Slice($slice);

print scalar @$vfs, "\n";

foreach my $vf (@$vfs) {
  print $vf->variation_name, ' ', join(', ', @{$vf->get_all_evidence_values}), "\n";
} 


