use strict;
use warnings;

use FileHandle;

my $dir = '/hps/nobackup/production/ensembl/anja/release_92/HC/';

my $fh_all = FileHandle->new("$dir/capra_hircus_variation_92_1_all_tables", 'r');
my $fh_master = FileHandle->new("$dir/master_schema_variation_92", 'r');

my $fh_non_master = FileHandle->new("$dir/capra_hircus_variation_92_1_non_master", 'w');


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
  if (!($table =~ /^MTMP/ || $master_tables->{$table})) {
    $non_master->{$table} = 1;
  }
}

print join(' ', keys %$non_master), "\n";
