=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016-2017] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=head1 CONTACT

 Ensembl <http://www.ensembl.org/info/about/contact/index.html>
    
=cut

=head1 NAME

 ExAC

=head1 SYNOPSIS

 ./vep -i variations.vcf --plugin AlleleFrequenciesFromVCF


=head1 DESCRIPTION

 A VEP plugin that retrieves ExAC allele frequencies.


=cut

package AlleleFrequenciesFromVCF;

use strict;
use warnings;

use Bio::EnsEMBL::Utils::Sequence qw(reverse_comp);
use Bio::EnsEMBL::Variation::Utils::Sequence qw(get_matched_variant_alleles);

use Bio::EnsEMBL::Variation::Utils::VEP qw(parse_line get_slice);

use Bio::EnsEMBL::Variation::Utils::BaseVepPlugin;

use base qw(Bio::EnsEMBL::Variation::Utils::BaseVepPlugin);

sub new {
  my $class = shift;
  
  my $self = $class->SUPER::new(@_);
  
  # test tabix
  die "ERROR: tabix does not seem to be in your path\n" unless `which tabix 2>&1` =~ /tabix$/;
  return $self;
}

sub feature_types {
  return ['Feature','Intergenic'];
}
sub get_header_info {
  my $self = shift;
  return {
  };
}
sub run {
  my ($self, $tva) = @_;
  my $vf = $tva->variation_feature;
  my $vca = $self->{config}->{reg}->get_adaptor($self->{config}->{species}, 'variation', 'VCFCollection');
  if ($vf->variation_name !~ /^rs/) {
  my $collections = $vca->fetch_all;
  foreach my $vc (@$collections) {
    my $alleles = $vc->get_all_Alleles_by_VariationFeature($vf);
    foreach my $allele (@$alleles) {
      print STDERR $vc->id, ' ', $vf->variation_name, ' ', $allele->population->name, ' ', $allele->allele, ' ', $allele->frequency, "\n";
    }
  }
  }
}

1;
