use strict;
use warnings;

use FileHandle;
use DBI;

my $host = '';
my $port = ;
my $user = '';
my $password = '';

my $dbh = DBI->connect("DBI:mysql:host=$host;port=$port;user=$user;password=$password", {RaiseError => 1});

my $fh = FileHandle->new('ens-var-2-88-post', 'r');

while (<$fh>) {
  chomp;
  my $database = $_;
  $dbh->do(qq{DROP database $database;});
}

$fh->close();
