use strict;
use warnings;

use DBI;
use FileHandle;

sub get_dbh {
  my $user_db_config = shift;
  my $fh = FileHandle->new($user_db_config, 'r');
  my $config = {};
  while (<$fh>) {
    chomp;
    my ($key, $value) = split/=/;
    $config->{$key} = $value;
  }
  $fh->close();
  my $database = $config->{database};
  my $host = $config->{host};
  my $user = $config->{user};
  my $port = $config->{port};
  my $password = $config->{password};
  my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host;port=$port;", $user, $password) or die $DBI::errstr;
  return $dbh;
}

1;
