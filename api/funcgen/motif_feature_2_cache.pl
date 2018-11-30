#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);
use Bio::EnsEMBL::Funcgen::DBSQL::DBAdaptor;
use Data::Dumper;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'mysql-ens-var-prod-3',
  -user => 'ensro',
  -port => 4606,
);


my $mfa = $registry->get_adaptor('human', 'funcgen', 'MotifFeature');
my $feature_id = 'ENSM00415292502';
my $mf = $mfa->fetch_by_stable_id($feature_id) or die "Failed to fetch MotifFeature for id: $feature_id";
my @epigenomes = sort map { $_->fetch_PeakCalling->fetch_Epigenome->name } @{$mf->fetch_all_overlapping_Peaks};
print 'Epigenomes ', join(', ', @epigenomes), "\n"; 
my $binding_matrix = $mf->binding_matrix;
my $binding_matrix_stable_id = $mf->stable_id;
my $transcription_factors = $binding_matrix->get_TranscriptionFactorComplex_names;
my $tf_label = join ",", @{$transcription_factors};
$mf->binding_matrix->summary_as_hash();
delete $mf->{slice}->{adaptor};
delete $mf->{slice}->{coord_system}->{adaptor};
delete $mf->{$_} for qw(
  adaptor
  binary_string
  bound_start
  bound_end
  attribute_cache
  feature_set
  analysis
  set
  _regulatory_activity
  _regulatory_build
);
#print Dumper($mf), "\n";

foreach my $tfc (@{$mf->{binding_matrix}->{associated_transcription_factor_complexes}}) {
  print join("\n", keys %$tfc), "\n";
}


