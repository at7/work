use strict;
use warnings;


use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('');
my $vdba = Bio::EnsEMBL::Registry->get_DBAdaptor('felis_catus', 'variation');
my $allele_adaptor = $vdba->get_AlleleAdaptor;

my %allele_id_2_string = reverse %{$allele_adaptor->_cache_allele_codes};

#print join("\n", keys %allele_id_2_string), "\n";

my $allele_code = $allele_adaptor->_allele_code('TCTGTAATTTCTCTGTAATTTCTCTGTAATTTC'); 

#print $allele_code, "\n";

my $sgta = $vdba->get_SampleGenotypeAdaptor;
my $gtca = $vdba->get_GenotypeCodeAdaptor;
my $gtcs = $gtca->fetch_all;
my $gtc_id_2_string = {};
foreach my $gtc (@$gtcs) {
  my $gtc_dbID = $gtc->dbID;
  my $alleles = join('/', @{$gtc->genotype});
  $gtc_id_2_string->{$gtc_dbID} = $alleles;
}
my $genotype_code_id = $sgta->_genotype_code([split('/', 'A/CCCCCCCCCGGGGTTTTTTTTT')]);
print $genotype_code_id, "\n";

