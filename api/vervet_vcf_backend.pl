use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_all('/hps/nobackup/production/ensembl/anja/release_96/vervet/ensembl.registry');

my $vfa = $registry->get_adaptor('vervet', 'variation', 'variationfeature');
my $sgta = $registry->get_adaptor('vervet', 'variation', 'samplegenotype');
my $sa = $registry->get_adaptor('vervet', 'core', 'slice'); 

$vfa->db->use_vcf(2);

my $slice = $sa->fetch_by_region('chromosome', 22, 1009570, 1019570);

my $vfs = $vfa->fetch_all_by_Slice($slice);
print STDERR 'VFS ', scalar @$vfs, "\n";

my $sgts = $sgta->fetch_all_by_Slice($slice);
print STDERR 'SGTS ', scalar @$sgts, "\n";



