use strict;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

my $file = '/lustre/scratch110/ensembl/at7/release_85/ensembl.registry';

$registry->load_all($file);

my $sgfa = $registry->get_adaptor('mouse', 'variation', 'samplegenotypefeature');
$sgfa->db->use_vcf(1);

my $slice_adaptor = $registry->get_adaptor('mouse', 'core', 'slice');
my $chr = 18;
my $start = 68_260_187; 
my $end = 68_300_333; 
my $slice = $slice_adaptor->fetch_by_region('chromosome', $chr, $start, $end);

my $pa = $registry->get_adaptor('mouse', 'variation', 'population');
my $sa = $registry->get_adaptor('mouse', 'variation', 'sample');


my $population = $pa->fetch_by_name('Mouse Genomes Project');
my $samples = $sa->fetch_all_by_name('MGP:CAST/EiJ');
my $sample = $samples->[0];


my $unique_sgfs = $sgfa->fetch_all_unique_by_Slice($slice, $sample, $population); 
print scalar @$unique_sgfs, "\n";
foreach my $sgf (@$unique_sgfs) {
  my $genotype_string = $sgf->genotype_string;
  my $vf = $sgf->variation_feature;
  my $variation_name = $vf->variation_name;
  my $seq_region_name = $vf->seq_region_name;
  my $seq_region_start = $vf->seq_region_start;
  my $seq_region_end = $vf->seq_region_end;
  my $allele_string = $vf->allele_string;
#  print "$variation_name $genotype_string $allele_string $seq_region_name $seq_region_start $seq_region_end\n";
}

my $differences_sgfs = $sgfa->fetch_all_differences_by_Slice($slice, $sample, $population); 
print scalar @$differences_sgfs, "\n";
foreach my $sgf (@$differences_sgfs) {
  my $genotype_string = $sgf->genotype_string;
  my $vf = $sgf->variation_feature;
  my $variation_name = $vf->variation_name;
  my $seq_region_name = $vf->seq_region_name;
  my $seq_region_start = $vf->seq_region_start;
  my $seq_region_end = $vf->seq_region_end;
  my $allele_string = $vf->allele_string;
  print "$variation_name $genotype_string $allele_string $seq_region_name $seq_region_start $seq_region_end\n";

  my $differences = $sgf->differences;
  foreach my $sample_name (keys %$differences) {
    my $genotype = $differences->{$sample_name};
    print "   $sample_name $genotype\n";
  }  

}

