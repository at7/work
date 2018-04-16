use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

my $va = $registry->get_adaptor('human', 'variation', 'variation');
$va->db->use_vcf(1);
my $variation = $va->fetch_by_name('rs770602');

my @alleles = @{$variation->get_all_Alleles};

foreach my $a (@alleles){
	my $freq = $a->frequency;
  if (defined $freq) {
    my $allele = $a->allele;
    my $population = (defined $a->population) ? $a->population->name : 'NA';
	  print $population, ' ', $allele, ' ', $freq, "\n";
  }
}


