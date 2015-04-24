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

package FinishVEP;

use strict;
use warnings;

use base ('Bio::EnsEMBL::Hive::Process');

use FileHandle;

sub run {
  my $self = shift;
  my $dir = $self->param('pipeline_dir');
  my $species = $self->param('species');

  my $fh = FileHandle->new("$dir/$species/FinishVEP.txt", 'w');
  print $fh "FinishVEP\n";
  $fh->close();
}

1;
