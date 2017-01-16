use strict;
use warnings;
use Bio::EnsEMBL::Registry;
use FileHandle;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

my $species = 'homo_sapiens';

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

#cmp_output();
run_script();

sub cmp_output {
  # ld_log_results, ld_log_results_fast
  my $cmp_hash = {};
  my $fh = FileHandle->new('ld_log_results', 'r');
  while (<$fh>) {
    chomp;
    if (/^\s+/) {
      $_ =~ s/^\s+//;
      my ($var1, $var2, $dprime, $r2) = split/\s/;
      $cmp_hash->{$var1}->{$var2}->{dprime} = $dprime;
      $cmp_hash->{$var1}->{$var2}->{r2} = $r2;
      $cmp_hash->{$var2}->{$var1}->{dprime} = $dprime;
      $cmp_hash->{$var2}->{$var1}->{r2} = $r2;
    }
  }  
  $fh->close;
  $fh = FileHandle->new('ld_log_results_fast', 'r');
  while (<$fh>) {
    chomp;
    if (/^\s+/) {
      $_ =~ s/^\s+//;
      my ($var1, $var2, $dprime, $r2) = split/\s/;
      my $test_dprime = $cmp_hash->{$var1}->{$var2}->{dprime};
      my $test_r2     = $cmp_hash->{$var1}->{$var2}->{r2};
      if ($test_dprime ne $dprime || $test_r2 ne $r2) {
        print "$var1 $var2\n";
      } 
    }
  }  
  $fh->close;

}

sub run_script {

my $population_adaptor = $vdba->get_PopulationAdaptor;
my $population_name = '1000GENOMES:phase_3:ACB';
my $population = $population_adaptor->fetch_by_name($population_name);
my $variation_adaptor = $vdba->get_VariationAdaptor;
my $ldfca = $vdba->get_LDFeatureContainerAdaptor;
$ldfca->db->use_vcf(1);
my $fh = FileHandle->new('ld_test_input', 'r');
my $log = FileHandle->new('ld_log_results_test', 'w');
while (<$fh>) {
  chomp;
  my $variant_name = $_;
  my $variation = $variation_adaptor->fetch_by_name($variant_name);
  my $vfs = $variation->get_all_VariationFeatures;
  my $vf = $vfs->[0];
  if ($vf) {
    my $start_time = time;

    my $LDFeatureContainer = $ldfca->fetch_by_VariationFeature($vf, $population);
    my @ld_values = @{$LDFeatureContainer->get_all_ld_values(1)};
    my $ld_count = scalar @ld_values;
    foreach my $ld_value (sort {$a->{d_prime} <=> $b->{d_prime} } @ld_values) {
      # population_id,variation_name1,variation1,variation_name2,variation2,d_prime,sample_count,r2
      my $variation_name1 = $ld_value->{variation_name1};
      my $variation_name2 = $ld_value->{variation_name2};
      my $d_prime = $ld_value->{d_prime};
      my $r2 = $ld_value->{r2};
      print $log  "    $variation_name1 $variation_name2 D_prime:$d_prime r2:$r2\n"; 
    }
    my $duration = time - $start_time;
    print $log "$variant_name\t$ld_count\t$duration\n";
  } else {
    print "No vf for $variant_name\n";
  }

}

$fh->close;

}

