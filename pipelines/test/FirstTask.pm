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

package FirstTask;

use strict;
use warnings;

use base ('BaseTest');

use FileHandle;

sub run {
  my $self = shift;
  my $species = $self->get_all_species();

  $self->param('species_list', $species);

  my $dir = $self->param('pipeline_dir');
  my $fh = FileHandle->new("$dir/FirstTask.txt", 'w');
  foreach my $hash (@$species) {
    my $species_name = $hash->{species};
    my $dbname = $hash->{dbname};
    print $fh "$species_name\t$dbname\n";
  }
  $fh->close();
}

sub write_output {
  my $self = shift;
  $self->dataflow_output_id($self->param('species_list'), 2);
  return;
}


1;
