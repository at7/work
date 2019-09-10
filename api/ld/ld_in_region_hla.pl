use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 97,
);

my $species = 'homo_sapiens';
my $dir = '/hps/nobackup2/production/ensembl/anja/release_98/ld/';

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

my $population_adaptor = $vdba->get_PopulationAdaptor;
my $slice_adaptor = $cdba->get_SliceAdaptor;
my $vf_adaptor = $vdba->get_VariationFeatureAdaptor;

my $population = $population_adaptor->fetch_by_name('1000GENOMES:phase_3:IBS');
my $ldFeatureContainerAdaptor = $vdba->get_LDFeatureContainerAdaptor;
$ldFeatureContainerAdaptor->db->use_vcf(1);
#HLA region on GRCh38 chr6:28,477,797-33,448,354
#6:31096931..31299414/1000GENOMES:phase_3:CEU?content-type=application/json
#We have a user getting errors trying to get LD on the HLA region. It just hangs on GRCh37:
#http://grch37.rest.ensembl.org/ld/human/region/6:31064708..31267191/1000GENOMES:phase_3:CEU?content-type=application/json
#And gives a 504 timeout on GRCh38:
#http://rest.ensembl.org/ld/human/region/6:31096931..31299414/1000GENOMES:phase_3:CEU?content-type=application/json#
#32427797 32527797
my $start = 28_477_797;
#my $start  = 32_527_797;
my $end = $start + 50_000;
my $region_end = 33_448_354;
my $step_size = 50_000;
while ($start < $region_end) {
  my $start_time = time;
  my $slice = $slice_adaptor->fetch_by_region('chromosome', 6, $start, $end);
  my $vf_count = $vf_adaptor->count_by_Slice_constraint($slice);
  my $ldfc = $ldFeatureContainerAdaptor->fetch_by_Slice($slice, $population);
  my @ld_values = @{$ldfc->get_all_ld_values(1)};
  my $pairs = 0;
  my $fh = FileHandle->new("$dir/$start\_$end", 'w');
  foreach my $hash (@ld_values) {
    my $variation1 = $hash->{variation_name1};
    my $variation2 = $hash->{variation_name2};
    my $r2 = $hash->{r2};
    my $d_prime = $hash->{d_prime};
    my $population_id = $hash->{population_id};
    $pairs++;
    print $fh "$variation1 $variation2 $r2 $d_prime $population_id\n";
  }
  $fh->close;
  my $duration = time - $start_time;
  print STDERR "$start $end $vf_count $pairs $duration\n";
  $start = $start + $step_size;
  $end =  $end + $step_size;
}

