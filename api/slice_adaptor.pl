use strict;
use warnings;


use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Slice qw(split_Slices);

=begin
my $registry = 'Bio::EnsEMBL::Registry';

my $file = '/hps/nobackup/production/ensembl/anja/release_90/pig/remapping/ensembl.registry.90';

$registry->load_all($file);

my $species = 'pig';

my $sa = $registry->get_adaptor($species, 'core', 'slice');


my $toplevel_slices = $sa->fetch_all('toplevel', undef, 1);
foreach my $slice (@$toplevel_slices) {
  print $slice->seq_region_name, ' ', $slice->get_seq_region_id, "\n";
}
=end
=cut


my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_95/cow/remapping_vcf/ensembl.registry.oldasm');

my $dbh = $registry->get_DBAdaptor('cow', 'variation')->dbc->db_handle;

my $sa = $registry->get_adaptor('cow', 'core', 'slice');

my $slice = $sa->fetch_by_region('toplevel', 'GJ057141.1');
my $chrom_end = $slice->seq_region_end;
print $chrom_end, "\n";
