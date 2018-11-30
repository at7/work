#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);
use Bio::EnsEMBL::Funcgen::DBSQL::DBAdaptor;


my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 94,
);


my $slice_adaptor = $registry->get_adaptor('human', 'core', 'slice');
my $slice = $slice_adaptor->fetch_by_region( 'chromosome', '13', 32_314_000, 32_317_500 );



