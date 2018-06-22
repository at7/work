use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry_file = '/hps/nobackup2/production/ensembl/anja/ensembl.registry';
my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all($registry_file);

my $species = $registry->get_all_species;

# core database: -> coord_system: coord_system_id->name
#                   seq_region: coord_system_id->seq_region_id->name = 1;  
# variation database:
# distinct seq_region_id from variation_feature, phenotype_feature, structural_variation_feature, transcript_variation 
# seq_region: how many coord_system_ids are represented
# meta_coord: is coord_system_id represented in meta_coord table 

foreach my $name (@$species) {
  next if ($name eq 'felis_catus');
  print STDERR $name, "\n";
  my $dbc = $registry->get_DBAdaptor($name, 'core')->dbc;
  my $core_dbname = $dbc->dbname;
  my $dbh = $registry->get_DBAdaptor($name, 'variation')->dbc->db_handle;
  my $all_seq_region_ids = {};
  my $all_coord_system_ids = {};
  my $sth = $dbh->prepare(qq{
    SELECT sr.seq_region_id, sr.name, csr.coord_system_id, ccs.name
    FROM seq_region sr
    LEFT JOIN $core_dbname.seq_region csr ON sr.seq_region_id = csr.seq_region_id
    LEFT JOIN $core_dbname.coord_system ccs ON csr.coord_system_id = ccs.coord_system_id;
  });

  $sth->execute();
  while (my $row = $sth->fetchrow_arrayref) {
    my ($seq_region_id, $name, $coord_system_id, $coord_system_name ) = @$row;
    $all_seq_region_ids->{$seq_region_id} = $coord_system_id;    
    if ($coord_system_id) {
      $all_coord_system_ids->{$coord_system_id} = 1;
    }
  }
  $sth->finish();

  my $vf_seq_region_ids = {};
  $sth = $dbh->prepare(qq{SELECT DISTINCT seq_region_id FROM variation_feature;});
  $sth->execute();
  while (my $row = $sth->fetchrow_arrayref) {
    my ($seq_region_id) = @$row;
    $vf_seq_region_ids->{$seq_region_id} = 1;
  }
  $sth->finish();
  my $covered_coord_system_ids = {};
  foreach my $seq_region_id (keys %$vf_seq_region_ids) {
    my $coord_system_id = $all_seq_region_ids->{$seq_region_id};
    $covered_coord_system_ids->{$coord_system_id}++;  
  }

  my $meta_coord = {};
  $sth = $dbh->prepare(qq{SELECT table_name, coord_system_id FROM meta_coord;});
  $sth->execute();
  while (my $row = $sth->fetchrow_arrayref) {
    my ($table_name, $coord_system_id) = @$row;
    $meta_coord->{$table_name}->{$coord_system_id} = 1;
  }
  $sth->finish();

  print STDERR "All coord system ids\n";
  print STDERR join(' ', sort keys %$all_coord_system_ids), "\n";
  print STDERR "Covered coord system ids\n";
  print STDERR join(' ', sort keys %$covered_coord_system_ids), "\n";
  print STDERR "Coord system ids in meta coord\n";
  foreach my $table_name (keys %$meta_coord) {
    print STDERR $table_name, ' ', join(' ', sort keys %{$meta_coord->{$table_name}}), "\n";
  }
  print STDERR "\n";

}


