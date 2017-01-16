use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

#my $assembly = 'grch37';
my $assembly = 'grch38';


if ($assembly eq 'grch37') {
  $registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous',
    -port => 3337,
  );
} else {
  $registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous',
  );
}

my $species = 'homo_sapiens';

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

my $slice_adaptor = $cdba->get_SliceAdaptor;
my $aefa = $cdba->get_AssemblyExceptionFeatureAdaptor;
my $vf_adaptor = $vdba->get_VariationFeatureAdaptor;

my $y = $slice_adaptor->fetch_by_region( 'chromosome', 'Y');
my @aefs = @{$aefa->fetch_all_by_Slice($y)};
foreach my $feature (@aefs) {

  print $feature->type, ' ', $feature->start, ' ', $feature->end,  "\n";
  
}

my $vfs = $vf_adaptor->fetch_all_by_Slice($y);
print scalar @$vfs, "\n";

