=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016-2018] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=cut

=head1 CONTACT

Please email comments or questions to the public Ensembl
developers list at <http://lists.ensembl.org/mailman/listinfo/dev>.

Questions may also be sent to the Ensembl help desk at
<http://www.ensembl.org/Help/Contact>.

=cut
package InitRemapping;

use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::Registry;

use base ('Bio::EnsEMBL::Hive::Process');

sub run {
  my $self = shift;
  my $registry_file = $self->param('registry_file');
  my $species      = $self->param('species');
  my $chroms_list = $self->param('chroms_list');
  my $registry = 'Bio::EnsEMBL::Registry';
  $registry->load_all($registry_file);
  my $dbh = $registry->get_DBAdaptor($species, 'variation')->dbc->db_handle;
  my @chroms = @{get_chroms($chroms_list)};
  my @input = ();
  foreach my $chrom (@chroms) {
    if ($self->has_mappings($dbh, $chrom)) {
      $self->warning("Has mappings $chrom");
      push @input, {
        chrom => $chrom,
      };
    }
  }
  $self->param('input', \@input);
}

sub write_output {
  my $self = shift;
  $self->dataflow_output_id($self->param('input'), 2);
}

sub get_chroms {
  my $file = shift;
  my @chroms = ();
  my $fh = FileHandle->new($file, 'r');
  while (<$fh>) {
    chomp;
    push @chroms, $_;
  }
  $fh->close;
  return \@chroms;
}

sub has_mappings {
  my $self = shift;
  my $dbh = shift;
  my $seq_region_name = shift;
  my $population = lc $self->param('population');
  my $sth = $dbh->prepare(qq{
    SELECT variation_id FROM vcf_variation_$population
    WHERE seq_region_name_old = ?
    AND variation_id IS NOT NULL
    LIMIT 1;
  }, {mysql_use_result => 1});
  $sth->execute($seq_region_name);
  my @row = $sth->fetchrow_array;
  $sth->finish();
  return $row[0];
}

1;
