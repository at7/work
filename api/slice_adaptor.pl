use strict;
use warnings;


use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Slice qw(split_Slices);

my $registry = 'Bio::EnsEMBL::Registry';

my $file = '/hps/nobackup/production/ensembl/anja/release_90/pig/remapping/ensembl.registry.90';

$registry->load_all($file);

my $species = 'pig';

my $sa = $registry->get_adaptor($species, 'core', 'slice');


my $toplevel_slices = $sa->fetch_all('toplevel', undef, 1);
foreach my $slice (@$toplevel_slices) {
  print $slice->seq_region_name, ' ', $slice->get_seq_region_id, "\n";
}
