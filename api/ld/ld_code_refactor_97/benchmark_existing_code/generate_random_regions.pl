use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'mysql-ens-mirror-1',
  -user => 'ensro',
  -port => 4240,
);

my $dir = '/hps/nobackup2/production/ensembl/anja/release_97/ld_code_refactoring/benchmark_old_code/';

my $slice_adaptor = $registry->get_adaptor('human', 'core', 'Slice'); 
my $vf_adaptor = $registry->get_adaptor('human', 'variation', 'VariationFeature');

my $fh = FileHandle->new("$dir/region_input", 'w');

foreach my $chrom (1..22, 'X', 'Y', 'MT') {
  my $chrom_slice = $slice_adaptor->fetch_by_region('chromosome', $chrom);
  my $end = $chrom_slice->seq_region_end;
  my $counts = 5;
  while ($counts) {
    my $random_start = int(rand($end - 1_000_000));
    $end = $random_start + 1_000_000;
    my $slice = $slice_adaptor->fetch_by_region('chromosome', $chrom, $random_start, $end); 
    my $vfs_count = $vf_adaptor->count_by_Slice_constraint($slice);
    print $fh join("\t", $chrom, $random_start, $end, $vfs_count), "\n";
    $counts--;
  }
}
$fh->close;
