=head1 LICENSE

Copyright (c) 1999-2013 The European Bioinformatics Institute and
Genome Research Limited.  All rights reserved.

This software is distributed under a modified Apache license.
For license details, please see

http://www.ensembl.org/info/about/legal/code_licence.html

=head1 CONTACT

Please email comments or questions to the public Ensembl
developers list at <dev@ensembl.org>.

Questions may also be sent to the Ensembl help desk at
<helpdesk@ensembl.org>.

=cut

package InitDump;

use strict;
use warnings;

use base ('BaseTest');

use Bio::EnsEMBL::Registry;

sub run {
  my $self = shift;
  my $species = $self->get_all_species(); 
  $self->param('species_list', $species);

}

sub write_output {
  my $self = shift;
  $self->dataflow_output_id($self->param('species_list'), 2);
  $self->dataflow_output_id($self->param('species_list'), 3);
  $self->dataflow_output_id($self->param('species_list'), 4);
  return;
}

1;
