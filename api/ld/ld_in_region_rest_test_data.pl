use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 97,
  -port => 3337,
);


my @samples = qw/NA19625 NA19700 NA19701 NA19703 NA19704 NA19707 NA19711 NA19712 NA19713 NA19818 NA19819 NA19834 NA19835 NA19900 NA19901 NA19904 NA19908 NA19909 NA19914 NA19916 NA19917 NA19920 NA19921 NA19922 NA19923 NA19982 NA19984 NA19985 NA20126 NA20127 NA20276 NA20278 NA20281 NA20282 NA20287 NA20289 NA20291 NA20294 NA20296 NA20298 NA20299 NA20314 NA20317 NA20322 NA20332 NA20334 NA20336 NA20339 NA20340 NA20341 NA20342 NA20344 NA20346 NA20348 NA20351 NA20356 NA20357 NA20359 NA20363 NA20412 NA20414/;

my $species = 'homo_sapiens';
my $dir = '/hps/nobackup2/production/ensembl/anja/release_98/ld/';

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

my $population_adaptor = $vdba->get_PopulationAdaptor;
my $slice_adaptor = $cdba->get_SliceAdaptor;
my $variation_adaptor = $vdba->get_VariationAdaptor;
$variation_adaptor->db->use_vcf(1);
my $vf_adaptor = $vdba->get_VariationFeatureAdaptor;
my $sample_adaptor = $vdba->get_SampleAdaptor;
=begin
my $population = $population_adaptor->fetch_by_name('1000GENOMES:phase_3:ASW');
my $ldFeatureContainerAdaptor = $vdba->get_LDFeatureContainerAdaptor;
$ldFeatureContainerAdaptor->db->use_vcf(1);
my $start = 31065708;
my $end = 31069708;
my $slice = $slice_adaptor->fetch_by_region('chromosome', 6, $start, $end);
my $vf_count = $vf_adaptor->count_by_Slice_constraint($slice);
my $ldfc = $ldFeatureContainerAdaptor->fetch_by_Slice($slice, $population);
my @ld_values = @{$ldfc->get_all_ld_values(1)};

my $variants = {};

foreach my $hash (@ld_values) {
  last if (scalar keys %$variants > 19);
  my $variation1 = $hash->{variation_name1};
  my $variation2 = $hash->{variation_name2};
  $variants->{$variation1} = 1;
  $variants->{$variation2} = 1;
  my $r2 = $hash->{r2};
  my $d_prime = $hash->{d_prime};
  my $population_id = $hash->{population_id};
  print "$variation1 $variation2 $r2 $d_prime $population_id\n";
}
foreach my $name (keys %$variants) {
  my $variation = $variation_adaptor->fetch_by_name($name);
  my ($vf) = grep {$_->slice->is_reference} @{$vf_adaptor->fetch_all_by_Variation($variation)};
  print $name, ' ', $vf->allele_string, "\n";
}
=end
=cut



my $name2sample = {};
foreach my $name (@samples) {
  my $sample_list = $sample_adaptor->fetch_all_by_name("1000GENOMES:phase_3:$name");
  my $sample = shift @$sample_list;
  if ($sample) {
    $name2sample->{$name} = $sample;
  } else {
    $name2sample->{$name} = undef;
  }


}

my $fh = FileHandle->new('vcf_chr6_grch37.vcf', 'w');
#print $fh "##fileformat=VCFv4.1\n";
#print $fh "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">\n";
#print $fh "##reference=GRCh37\n";
#my @header_names = qw/#CHROM  POS ID  REF ALT QUAL  FILTER  INFO  FORMAT/;
#print $fh join("\t", @header_names), "\t", join("\t", @samples), "\n";


my $in = FileHandle->new('ld_chr9.vcf', 'r');
while (<$in>) {
  chomp;
  print $fh $_, "\n";
}
$in->close;



my @variants = qw/rs2394878 rs562436031 rs9263526 rs2535284 rs9263509 rs9263525 rs3130548 rs2517556 rs9263529 rs9263513 rs9263537 rs2394877 rs2535282 rs9263566 rs2517558/;
#9 22124504  rs1333047 A T 100 PASS  . GT
foreach my $name (@variants) {
  print $name, "\n";
  my $variation = $variation_adaptor->fetch_by_name($name);
  my ($vf) = grep {$_->slice->is_reference} @{$vf_adaptor->fetch_all_by_Variation($variation)};
  my $allele_string = $vf->allele_string;
  my $chr = $vf->seq_region_name;
  my $start = $vf->seq_region_start;
  my ($ref, $alt) = split('/', $allele_string);
  my @genotypes_for_variant = (); 

  foreach my $sample_name (@samples) {
    my $sample = $name2sample->{$sample_name};
    if ($sample) {
      my $sample_genotypes = $variation->get_all_SampleGenotypes($sample); 
      my $sample_genotype = shift @$sample_genotypes;
      my @genotypes = split('\|', $sample_genotype->genotype_string);
      my @genotype_indices = ();
      foreach my $allele (@genotypes) {
        push @genotype_indices, 0 if ($allele eq $ref);
        push @genotype_indices, 1 if ($allele eq $alt);
      }
      push @genotypes_for_variant, join('|', @genotype_indices); 
    } else {
      push @genotypes_for_variant, '.|.'; 
    }
  }
  
  print $fh join("\t", $chr, $start, $name, $ref, $alt, 100, 'PASS', '.', 'GT'), "\t", join("\t", @genotypes_for_variant), "\n";
}

$fh->close;

