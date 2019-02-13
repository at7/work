use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -port => 3337,
  -species => 'homo sapiens',
);

my $variation_adaptor = $registry->get_adaptor("human", "variation", "variation");

# Set a flag on the variation adaptor to use VCF files for genotype extraction as well as the MySQL database
$variation_adaptor->db->use_vcf(1);

my @rsIDs = qw(rs1367827 rs1367830 rs1333049);

foreach my $ID (@rsIDs) {
  my $variation = $variation_adaptor->fetch_by_name($ID);
  my $alleles = $variation->get_all_Alleles();

    foreach my $allele (@{$alleles}) {
    next unless (defined $allele->population && $allele->population->name =~ /gnomADg:ALL/);
    my $allele_string   = $allele->allele;
    my $frequency       = $allele->frequency || 'NA';
    my $population_name = $allele->population->name;
    printf("%s Allele %s has frequency: %s in population %s.\n", $ID, $allele_string, $frequency, $population_name);
  }
}
