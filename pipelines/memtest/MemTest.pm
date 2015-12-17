package MemTest;

use strict;
use warnings;

use base ('Bio::EnsEMBL::Hive::Process');

sub run {
  my $self = shift;
#  my $count = 10000000;
#  my $hash = {};
#  while ($count > 1) {
#    $hash->{$count} = 1;
#    $count--;
#  }
  $self->warning('completed');
}

sub write_output {
  my $self = shift;
  my $new_count = 4;
  my @input = ();
  while ($new_count > 0) {
    push @input, {count => $new_count}; 
    $self->warning($new_count);
    $new_count--;
  }
  $self->dataflow_output_id(\@input, 2);
}

1;
