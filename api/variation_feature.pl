use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Getopt::Long;
use File::Path qw(make_path);
# perl individuals.pl -db_config db_config

my $config = {};

GetOptions(
  $config,
  'db_config=s',
  'registry=s',
  'working_dir=s',
) or die "Error: Failed to parse command line arguments\n";

main();

sub main {
  my $registry = 'Bio::EnsEMBL::Registry';
  $registry->load_all($config->{'registry'});
  my $vdbas = $registry->get_all_DBAdaptors(-group => 'variation');
  my $species = {};
  foreach my $vdba (@$vdbas) {
    divide_variation_feature($vdba);
  }
}


sub divide_variation_feature {
  my $vdba = shift;
  my $dbh = $vdba->dbc->db_handle;
  my $species_name = $vdba->species();
  my $working_dir = $config->{'working_dir'};
  $working_dir .= "/$species_name";
  make_path($working_dir);

  my ($sr_dir, $fh);
  my $vf_count = 1;
  my $file_count = 0;
  my $prev_sr_name = 0;
  my $stmt = qq{SELECT vf.variation_feature_id, sr.name FROM variation_feature vf, seq_region sr WHERE sr.seq_region_id = vf.seq_region_id ORDER BY vf.seq_region_id;};

  my $sth = $dbh->prepare($stmt) or die $dbh->errstr;
  $sth->execute() or die $sth->errstr;

  while (my $row = $sth->fetchrow_arrayref) {
    my $vf_id = $row->[0];
    my $sr_name = $row->[1];
    
    if ($sr_name ne $prev_sr_name) {
      $fh->close() if (defined $fh);
      $sr_dir = "$working_dir/$sr_name";
      make_path($sr_dir);
      $file_count++;
      $fh = FileHandle->new("$sr_dir/$file_count.txt", 'w');
      if ($vf_count == 500_000) {
        $vf_count = 0;
      }
    }  
     
    if ($vf_count == 500_000) {
      $fh->close;
      $file_count++;
      $fh = FileHandle->new("$sr_dir/$file_count.txt", 'w');
      $vf_count = 0;
    } 

    print $fh "$vf_id\n";
    $vf_count++;


    $prev_sr_name = $sr_name;

  }

  $sth->finish();

}




