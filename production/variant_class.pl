use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;


my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -user => 'ensro',
    -host => 'mysql-ens-var-prod-2',
    -port => 4521,
    -db_version => 92,
);

my $va = $registry->get_adaptor('zebrafish', 'variation', 'variation');

my $dbh = $va->dbc->db_handle;


my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/HC/zebrafish_old_deletions_92', 'w');

my $sth = $dbh->prepare(qq{
  select name, class_attrib_id, display from variation where name = ?;
});

my $fh_in = FileHandle->new('err', 'r');
while (<$fh_in>) {
  chomp;
  $sth->execute($_) or die 'Could not execute statement ' . $sth->errstr;
  my ($name, $class, $display);
  $sth->bind_columns(\($name, $class, $display));
  while ($sth->fetch) {
    $display ||= 'failed';
    print $fh $name, ' ', $class, ' ', $display, "\n";
  }
}

$sth->finish();
$fh_in->close();
$fh->close;



if (0) {
my $v91 = {};

my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/HC/zebrafish_deletions_92', 'r');
while (<$fh>) {
  chomp;
  $v91->{$_} = 1;
}
$fh->close;

$fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/HC/zebrafish_deletions_91', 'r');
while (<$fh>) {
  chomp;
  if (!$v91->{$_}) {
    print STDERR $_, "\n";
  }
}
$fh->close;
}


if (0) {
my $registry = 'Bio::EnsEMBL::Registry';
#$registry->load_registry_from_db(
#    -user => 'ensro',
#    -host => 'mysql-ensembl-mirror',
#    -port => 4240,
#    -db_version => 91,
#);

$registry->load_registry_from_db(
    -user => 'ensro',
    -host => 'mysql-ens-var-prod-2',
    -port => 4521,
    -db_version => 92,
);

my $va   = $registry->get_adaptor('zebrafish', 'variation', 'variation');

my $dbh = $va->dbc->db_handle;


my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/HC/zebrafish_deletions_92', 'w');


my $sth = $dbh->prepare(qq{
  select name from variation where class_attrib_id = 12;
});
$sth->execute() or die 'Could not execute statement ' . $sth->errstr;
my ($name);
$sth->bind_columns(\$name);
while ($sth->fetch) {
  print $fh $name, "\n";
}
$sth->finish();
$fh->close;
}
