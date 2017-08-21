use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Slice qw(split_Slices);
use FileHandle;

my $registry = 'Bio::EnsEMBL::Registry';

my $file = '/hps/nobackup/production/ensembl/anja/release_90/ensembl.registry.v2';

$registry->load_all($file);

my $vdbas = $registry->get_all_DBAdaptors(-group => 'variation');

my $global_split_size = 5e5;

foreach my $vdba (@$vdbas) {
  my $species_name = $vdba->species();
  my $fh = FileHandle->new("/hps/nobackup/production/ensembl/anja/release_90/split_slice_statistics/$species_name", 'w');
  my $vfa = $registry->get_adaptor($species_name, 'variation', 'variationfeature');
  my $sa = $registry->get_adaptor($species_name, 'core', 'slice');
  my $dbh = $vdba->dbc->db_handle;
  my $toplevel_slices = $sa->fetch_all('toplevel');
  foreach my $toplevel_slice (@$toplevel_slices) {
    my $seq_region_id = $toplevel_slice->get_seq_region_id;
    my $seq_region_name = $toplevel_slice->seq_region_name;
    my $sth = $dbh->prepare(qq/select count(*) from variation_feature where seq_region_id=$seq_region_id and display = 1;/);
    $sth->execute() or die $sth->errstr;
    my $count = $sth->fetchrow_arrayref->[0];
    if ($count > 0) {
      my $sub_slices = $count / $global_split_size;
      print $fh "$seq_region_name\t$seq_region_id\t$count\t$sub_slices\n";
    }
    $sth->finish;
  }
  $fh->close;
}

