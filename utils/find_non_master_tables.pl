use strict;
use warnings;

use FileHandle;

my $dir = '/hps/nobackup2/production/ensembl/anja/release_96/HC/';

my $fh_all = FileHandle->new("$dir/variation_tables_96", 'r');
my $fh_master = FileHandle->new("$dir/master_schema_variation_96", 'r');


my $master_tables = {};
while (<$fh_master>) {
  chomp;
  $master_tables->{$_} = 1;
}
$fh_master->close();


my $all_tables = {};
while (<$fh_all>) {
  chomp;
  $all_tables->{$_} = 1;
}
$fh_all->close();


my $non_master = {};

foreach my $table (keys %$all_tables) {
  if (!($master_tables->{$table})) {
    $non_master->{$table} = 1;
  }
}

my $fh = FileHandle->new("$dir/non_master_schema_variation_96", 'w');

print $fh join(' ', keys %$non_master), "\n";

$fh->close;
