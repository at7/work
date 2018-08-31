use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_94/vervet/ensembl.registry');

my $vfa = $registry->get_adaptor('vervet', 'variation', 'variationfeature');
my $sa = $registry->get_adaptor('vervet', 'core', 'slice'); 

$vfa->db->use_vcf(1);

my $slice = $sa->fetch_by_region('chromosome', 3, 1, 5000000);

my $vfs = $vfa->fetch_all_by_Slice($slice);

print scalar @$vfs, "\n";



