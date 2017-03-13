use strict;
use warnings;
use Bio::EnsEMBL::Registry;
use FileHandle;
my $registry = 'Bio::EnsEMBL::Registry';

#$registry->load_registry_from_db(
#    -host => 'ensembldb.ensembl.org',
#    -user => 'anonymous',
#    -port => 3337
#);
my $file = '/hps/nobackup/production/ensembl/anja/release_88/human/ensembl.registry.88';

my $variation_input = '/hps/nobackup/production/ensembl/anja/hapmap/38/input_single_variant';
my $output = '/hps/nobackup/production/ensembl/anja/hapmap/38/output_single_variant';

my $fh = FileHandle->new($variation_input, 'r');
my $fh_out = FileHandle->new($output, 'w');

$registry->load_all($file);
my $variation_adaptor = $registry->get_adaptor('human', 'variation', 'variation');
my $population_adaptor = $registry->get_adaptor('human', 'variation', 'population');
$variation_adaptor->db->use_vcf(1);

my @hapmap_populations = qw/ CSHL-HAPMAP:HapMap-CEU CSHL-HAPMAP:HapMap-HCB CSHL-HAPMAP:HapMap-JPT CSHL-HAPMAP:HapMap-YRI CSHL-HAPMAP:HAPMAP-ASW CSHL-HAPMAP:HAPMAP-CHB CSHL-HAPMAP:HAPMAP-CHD CSHL-HAPMAP:HAPMAP-GIH CSHL-HAPMAP:HAPMAP-LWK CSHL-HAPMAP:HAPMAP-MEX CSHL-HAPMAP:HAPMAP-MKK CSHL-HAPMAP:HAPMAP-TSI/;

while (<$fh>) {
  chomp;
  my $name = $_;
  foreach my $population_name (@hapmap_populations) {  
    my $variation = $variation_adaptor->fetch_by_name($name);
    my $population = $population_adaptor->fetch_by_name($population_name);

    my @alleles = @{$variation->get_all_Alleles($population)};
    foreach my $allele (@alleles) {
      my $rounded = sprintf("%.3f", $allele->frequency);
      print $fh_out join("\t", $name, $population_name,  $allele->allele, $allele->count, $rounded, $allele->population->name, $allele->subsnp), "\n";
    }
    print $fh_out "\n\n";
    my @pgts = @{$variation->get_all_PopulationGenotypes($population)};
    foreach my $pgt (@pgts) {
      my $rounded = sprintf("%.3f", $pgt->frequency);
      print $fh_out join("\t", $name, $population_name,  $pgt->genotype_string, $pgt->count, $rounded), "\n";
    }
  }
  print $fh_out "\n";
}

$fh->close;
$fh_out->close;
