use strict;
use warnings;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Variation::Population;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 97,
);

my $va = $registry->get_adaptor('human', 'variation', 'variation');
$va->db->use_vcf(2);
my $variation = $va->fetch_by_name('rs2359294');

my @alleles = @{$variation->get_all_Alleles()};

foreach my $a (@alleles){
	my $freq = $a->frequency;
  if (defined $freq) {
    my $allele = $a->allele;
    my $population = (defined $a->population) ? $a->population->name : 'NA';
	  print $population, ' ', $allele, ' ', $freq, "\n";
  }
}


