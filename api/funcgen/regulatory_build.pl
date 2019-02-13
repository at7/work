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


my $regulatory_build_adaptor = $registry->get_adaptor('human', 'funcgen', 'regulatorybuild');


print $regulatory_build_adaptor, "\n";

my $regulatory_build = $regulatory_build_adaptor->fetch_current_regulatory_build;

foreach my $cell_type (@{$regulatory_build->get_all_Epigenomes}) {
  print $cell_type->display_label, "\n";

}

#    my $cell_types = [
#      sort
#      map {{ value => $_->production_name, caption => $_->display_label }}
#      @{$regulatory_build->get_all_Epigenomes}
#    ];


