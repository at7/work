use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_96/cow/transcript_variation/ensembl.registry');

my $sa = $registry->get_adaptor('cow', 'core', 'slice'); 

my $slice = $sa->fetch_by_region('primary_assembly', 'MT');

print $slice, "\n";





