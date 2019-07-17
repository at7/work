use strict;
use warnings;

use FileHandle;
use DBI;

#--host mysql-ens-var-prod-1 --port 4449 --user ensadmin --pass
#--host mysql-ens-var-prod-2 --port 4521 --user ensadmin --pass
my $host = 'mysql-ens-var-prod-1';
my $port = 4449;
my $user = 'ensadmin';
my $password = '';

my $dbh = DBI->connect("DBI:mysql:host=$host;port=$port;user=$user;password=$password", {RaiseError => 1});

my $fh = FileHandle->new('/homes/anja/bin/work/utils/variation_98.txt', 'r');

while (<$fh>) {
  chomp;
  my $database = $_;
  print STDERR "Drop database $database;\n";
  $dbh->do(qq{DROP database $database;});
}

$fh->close();
