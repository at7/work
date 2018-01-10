use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::Registry;
#chromosome 2
#17:72121020-72126420

my $config = {};

my $species = 'homo_sapiens';

my $registry = 'Bio::EnsEMBL::Registry';

if ($config->{registry_file}) {
  $registry->load_all($config->{registry_file});
} else {
  $registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous',
    -DB_version => 90,
  );
}

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

my $population_adaptor = $vdba->get_PopulationAdaptor;
my $variation_adaptor = $vdba->get_VariationAdaptor;
my $slice_adaptor = $cdba->get_SliceAdaptor;
$variation_adaptor->db->use_vcf(1);
my $ldFeatureContainerAdaptor = $vdba->get_LDFeatureContainerAdaptor;


my $populations = {
0 => '1000GENOMES:phase_3:ACB',
1 => '1000GENOMES:phase_3:ASW',
2 => '1000GENOMES:phase_3:BEB',
3 => '1000GENOMES:phase_3:CDX',
4 => '1000GENOMES:phase_3:CEU',
5 => '1000GENOMES:phase_3:CHB',
6 => '1000GENOMES:phase_3:CHS',
7 => '1000GENOMES:phase_3:CLM',
8 => '1000GENOMES:phase_3:ESN',
9 => '1000GENOMES:phase_3:FIN',
10 => '1000GENOMES:phase_3:GBR',
11 => '1000GENOMES:phase_3:GIH',
12 => '1000GENOMES:phase_3:GWD',
13 => '1000GENOMES:phase_3:IBS',
14 => '1000GENOMES:phase_3:ITU',
15 => '1000GENOMES:phase_3:JPT',
16 => '1000GENOMES:phase_3:KHV',
17 => '1000GENOMES:phase_3:LWK',
18 => '1000GENOMES:phase_3:MSL',
19 => '1000GENOMES:phase_3:MXL',
20 => '1000GENOMES:phase_3:PEL',
21 => '1000GENOMES:phase_3:PJL',
22 => '1000GENOMES:phase_3:PUR',
23 => '1000GENOMES:phase_3:STU',
24 => '1000GENOMES:phase_3:TSI',
25 => '1000GENOMES:phase_3:YRI',
};

#my $count = 0;
#foreach my $population (@{$population_adaptor->fetch_all_1KG_Populations}) {
#  if ($population->name =~ /phase_3/ && $population->name !~ /ALL|AFR|EUR|ASN|SAS|EAS|AMR/) {
#    print "$count => '" . $population->name . "'," , "\n";
#    $count++;
#  }
#}

my $test_cases = 0;


while ($test_cases < 20) {
  my $chrom = get_random_chromosome();
  my $slice = $slice_adaptor->fetch_by_region('chromosome', $chrom);
  my $end = $slice->seq_region_end;
  my $random_start = int(rand($end - 1_000_000));
  $end = $random_start + 1_000_000;

  print STDERR "$chrom $random_start $end\n";

#  my $random_population = $populations->{int(rand(26))};
#  my $population = $population_adaptor->fetch_by_name($random_population);

  $slice = $slice_adaptor->fetch_by_region('chromosome', $chrom, $random_start, $end);

  foreach my $population_name (values %$populations) {
    my $population = $population_adaptor->fetch_by_name($population_name);

    my $fh = FileHandle->new("/hps/nobackup/production/ensembl/anja/ld/tool_limit_tests/$population_name\_$chrom\_$random_start\_$end", 'w');
    my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_Slice($slice, $population);
    my $ld_values = $ldFeatureContainer->get_all_ld_values(1);
    foreach my $ld_value (@$ld_values) {
      my $variation_name1 = $ld_value->{variation_name1};
      my $variation_name2 = $ld_value->{variation_name2};
      my $r2 = $ld_value->{r2};
      my $d_prime = $ld_value->{d_prime};
      print $fh join(" ", $variation_name1, $variation_name2, $r2, $d_prime), "\n";
    }
    $fh->close();
  }
  $test_cases++;
}

sub test_pairwise {
my $population = $population_adaptor->fetch_by_name('1000GENOMES:phase_3:GBR');

my $vf_input = {};
my $vf_count = 0;
my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/ld/input_for_pairwise', 'r');

my @vfs = ();

while (<$fh>) {
  chomp;
  next if ($vf_input->{$_});
  if ($vf_count <= 99) {
    print STDERR "$_\n";    
    my $vf = $variation_adaptor->fetch_by_name($_)->get_all_VariationFeatures->[0];
    push @vfs, $vf;
    $vf_count++;
  }
  $vf_input->{$_} = 1;
}

$fh->close();

print scalar @vfs, "\n";
my $ldFeatureContainerAdaptor = $vdba->get_LDFeatureContainerAdaptor;
my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_VariationFeatures(\@vfs, $population);
my $ld_values = $ldFeatureContainer->get_all_ld_values(1);
foreach my $ld_value (@$ld_values) {
  my $variation_name1 = $ld_value->{variation_name1};
  my $variation_name2 = $ld_value->{variation_name2};
  my $r2 = $ld_value->{r2};
  my $d_prime = $ld_value->{d_prime};
  print STDERR join(" ", $variation_name1, $variation_name2, $r2, $d_prime), "\n";
}
}
sub ld_in_region {
my $chr = 6;
my $start = 72126420;
my $end = $start + 550_000;

my $slice = $slice_adaptor->fetch_by_region('chromosome', $chr, $start, $end);

my $population = $population_adaptor->fetch_by_name('1000GENOMES:phase_3:GBR');

my $ldFeatureContainerAdaptor = $vdba->get_LDFeatureContainerAdaptor;
my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_Slice($slice, $population);

my $file_name = join('_', $chr, $start, $end, 'GBR', 'vf_objects');
my $fh = FileHandle->new("/hps/nobackup/production/ensembl/anja/ld/input_for_pairwise", 'w');

my $ld_values = $ldFeatureContainer->get_all_ld_values(0);
foreach my $ld_value (@$ld_values) {
  my $variation_name1 = $ld_value->{variation_name1};
  my $variation_name2 = $ld_value->{variation_name2};
  my $r2 = $ld_value->{r2};
  my $d_prime = $ld_value->{d_prime};
#  print $fh join(" ", $variation_name1, $variation_name2, $r2, $d_prime), "\n";
  print $fh "$variation_name1\n";
}

$fh->close;
}



sub get_random_chromosome {
  my $random_number = int(rand(22)) + 1;
  return 'X' if ($random_number == 21);
  return 'Y' if ($random_number == 22);
  return $random_number;
}

