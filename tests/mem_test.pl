use strict;
use warnings;


my $count = 10000000;


my $hash = {};
while ($count > 1) {
  $hash->{$count} = 1;
  $count--;
}


