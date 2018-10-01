use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_94/chicken/remapping/ensembl.registry.oldasm');
my $vdba = $registry->get_DBAdaptor('chicken', 'variation');
my $cdba =  $registry->get_DBAdaptor('chicken', 'core');


my $variation_adaptor = $vdba->get_VariationAdaptor;

my $variation = $variation_adaptor->fetch_by_name('rs3136833');


#my $dbh = $vdba->dbc->db_handle();
#  my $sth = $dbh->prepare(qq{
#    SELECT $column_names_string FROM $feature_table WHERE seq_region_id = ? $extra_sql;
#  }, {mysql_use_result => 1});
my $sa = $cdba->get_SliceAdaptor;
my $slices = $sa->fetch_all('toplevel', undef, 0, 1);
my $seq_region_ids = {};
foreach my $slice (@$slices) {
  my $seq_region_name = $slice->seq_region_name;
  next if ($seq_region_name =~ /PATCH/);
  my $seq_region_id = $slice->get_seq_region_id;
  $seq_region_ids->{$seq_region_id} = $seq_region_name;
}

my $dbh = $vdba->dbc->db_handle();
my $sth = $dbh->prepare(qq{
  SELECT * FROM structural_variation_feature WHERE seq_region_id = ?;
}, {mysql_use_result => 1});


foreach my $seq_region_id (keys %$seq_region_ids) {
  my $seq_region_name = $seq_region_ids->{$seq_region_id};
  $sth->execute($seq_region_id) or die $sth->errstr;
  my $count = 0;
  while (my $row = $sth->fetchrow_arrayref) {
    $count++;
  }
  print STDERR "$seq_region_id $count\n" if ($count > 0);
  $sth->finish();
}
