package Computation;

use strict;
use warnings;

use base ('Bio::EnsEMBL::Hive::Process');

sub run {
  my $self = shift;  
  my $count = $self->param('count');
  $self->warning("count $count");
  $count = 7000000;
  my $hash = {};
  while ($count > 0) {
    $hash->{$count} = 1;
    $count--;
  }  
}

1;
