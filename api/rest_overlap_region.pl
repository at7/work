use strict;
use warnings;

use Bio::EnsEMBL::MappedSliceContainer;
use Bio::EnsEMBL::DBSQL::StrainSliceAdaptor;
use Bio::EnsEMBL::Registry;

my $reg = 'Bio::EnsEMBL::Registry';

$reg->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

my $va   = $reg->get_adaptor('human', 'variation', 'Variation');
my $vfa  = $reg->get_adaptor('human', 'variation', 'VariationFeature');

my $variation_name = 'rs997489';


my $variation = $va->fetch_by_name($variation_name);

my $vfs = $variation->get_all_VariationFeatures;

print scalar @$vfs, "\n";


foreach my $vf (@$vfs) {
  my $summary_ref = $vf->summary_as_hash;
  my $consequence_type = $summary_ref->{'consequence_type'};
  print "consequence_type $consequence_type\n";
  my @alleles = @{$summary_ref->{'alleles'}};
  print 'alleles ', join(', ', @alleles), "\n";
  my @clinical_significance = @{$summary_ref->{'clinical_significance'}};
  print 'clinical_significance ', join(', ', @clinical_significance), "\n";
  my $minor_allele = $summary_ref->{'minor_allele'};
  print "minor allele $minor_allele\n";
  my $minor_allele_frequency = $summary_ref->{'minor_allele_frequency'};
  print "minor allele frequency $minor_allele_frequency\n";
  my $minor_allele_count = $summary_ref->{'minor_allele_count'};
  print "minor allele count $minor_allele_count\n";
  my $var_class = $summary_ref->{'var_class'};
  print "var_class $var_class\n";
  my @evidence_values = @{$summary_ref->{'evidence_values'}};
  print 'evidence_values ', join(', ', @evidence_values), "\n";
}
