use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Slice qw(split_Slices);
use FileHandle;

my $global_vf_count_in_species = 5_000_000; # if number of vf in a species exceeds this we need to split up dumps
my $max_vf_load = 2_000_000; # group slices together until the vf count exceeds max_vf_load
my $vf_per_slice = 2_000_000; # if number of vf exceeds this we split the slice and dump for each split slice
my $max_split_slice_length = 500_000;
my $gvf_dump_split_slice_length = 1000;
my $overlap = 1;

my $registry = 'Bio::EnsEMBL::Registry';
my $file = '/hps/nobackup/production/ensembl/anja/release_90/ensembl.registry.v2';
$registry->load_all($file);
my $vdbas = $registry->get_all_DBAdaptors(-group => 'variation');

foreach my $vdba (@$vdbas) {
  my $species = $vdba->species();
  my $vfa = $registry->get_adaptor($species, 'variation', 'variationfeature');
  my $sa = $registry->get_adaptor($species, 'core', 'slice');
  my $slices = $sa->fetch_all('chromosome');

  foreach my $slice (@$slices) {
    print STDERR "$species ", $slice->seq_region_name, ' ', $slice->length, ' ', $slice->length / 5e6, "\n"; 
  }

}

