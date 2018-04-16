use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

my $sva = $registry->get_adaptor("human", "variation", "structuralvariation");
my $svpfa = $registry->get_adaptor("human","variation","structuralvariationpopulationfrequency");


my $svfa = $registry->get_adaptor("human", "variation", "structuralvariationfeature");

my $sa =  $registry->get_adaptor("human", "core", "slice");

my $slice = $sa->fetch_by_region('chromosome', 7, 140424943, 140624564);
my $svs = $svfa->fetch_all_by_Slice_SO_term($slice, '');

print scalar @$svs, "\n";
