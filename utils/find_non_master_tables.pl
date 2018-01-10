use strict;
use warnings;

use FileHandle;

my $fh_all = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_91/HC/gallus_gallus_91_5_all_tables', 'r');
my $fh_master = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_91/HC/variation_master_tables', 'r');

my $fh_non_master = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_91/HC/gallus_gallus_master_tables', 'w');


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
