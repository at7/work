use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;


my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_95/chicken/ensembl.registry.newasm');

my $dbh = $registry->get_DBAdaptor('chicken', 'variation')->dbc->db_handle;


$dbh->do(qq{Truncate table read_coverage; });

my $slice_adaptor = $registry->get_adaptor('chicken', 'core', 'slice');


my $slices = $slice_adaptor->fetch_all('chromosome'); 
foreach my $slice (@$slices) {
  my $seq_region_id = $slice->get_seq_region_id;
  my $seq_region_start  = $slice->seq_region_start;
  my $seq_region_end = $slice->seq_region_end;
  foreach my $sample_id (1,2,3,4) {
    $dbh->do(qq{INSERT INTO read_coverage(seq_region_id, seq_region_start, seq_region_end, level, sample_id) VALUES($seq_region_id, $seq_region_start, $seq_region_end, 1, $sample_id)});
  }
}
