use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous'
);

my $va = $registry->get_adaptor('human', 'variation', 'variation');
my $v = $va->fetch_by_name('rs2470893');

# Fetch all the phenotype features associated with the variation
my $pfa = $registry->get_adaptor('homo_sapiens', 'variation', 'phenotypefeature');
$pfa->_include_ontology(1);
foreach my $pf (@{$pfa->fetch_all_by_Variation($v)}) {
  my $phenotype_description = $pf->phenotype_description;
  my $study_description = $pf->study_description;
  my $source_name = $pf->source_name;
  my $associated_gene = $pf->associated_gene;
  my $risk_allele = $pf->risk_allele;
  my $ontology_accessions = join(', ', @{$pf->get_all_ontology_accessions});
  print STDERR "$phenotype_description $study_description $source_name $associated_gene $risk_allele $ontology_accessions\n";


#  print "Variation ", $pf->variation_names, " is associated with the phenotype '", $pf->phenotype->description,
#    "' in source ", $pf->source_name;
#  print " with a p-value of ",$pf->p_value if (defined($pf->p_value));
#  print ".\n";
#  print "The risk allele is ", $pf->risk_allele, ".\n" if (defined($pf->risk_allele));
}
