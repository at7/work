use strict;
use warnings;

use Bio::EnsEMBL::Registry;
my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous',
);


my $species = 'turkey';
my $variation_adaptor = $registry->get_adaptor($species, 'variation', 'variation');
#my $slice_adaptor = $registry->get_adaptor('human', 'core', 'slice');
#my $slice = $slice_adaptor->fetch_by_region('chromosome','6',133017695,133161157); 
my $vf_adaptor = $registry->get_adaptor($species, 'variation', 'variationfeature');

$vf_adaptor->db->include_failed_variations(1);

my $vfs = $vf_adaptor->fetch_all(); 

print "There are " . scalar(@{$vfs}) . " variants\n";
