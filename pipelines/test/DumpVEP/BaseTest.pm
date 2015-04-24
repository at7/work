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

package BaseTest;

use strict;
use warnings;

use base ('Bio::EnsEMBL::Hive::Process'); 

use Bio::EnsEMBL::Registry;

sub run_cmd {
    my $self = shift;
    my $cmd = shift;
    if (my $return_value = system($cmd)) {
        $return_value >>= 8;
        die "system($cmd) failed: $return_value";
    }
}

sub get_all_species {
  my $self = shift;
  my $registry = 'Bio::EnsEMBL::Registry';
  $registry->load_all($self->param('registry_file'));
  my $vdbas = $registry->get_all_DBAdaptors(-group => 'variation');
  my @species = ();
  foreach my $vdba (@$vdbas) {
    my $species_name = $vdba->species();
    my $dbname = $vdba->dbname();
    if ($species_name) {
      push @species, {species => $species_name, dbname => $dbname} if ($species_name);
    }
  }
  return \@species;
}

1;
