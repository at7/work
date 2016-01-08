use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Data::Dumper;
use FileHandle;


my $start_time = time;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 83,
);

# input
#previous_seq_region_id, $snp_start, $snp_start, $population, $sample_id, $sample_information->{$population}{$snp_start}{$sample_id}{genotype})
#0 48903756  48903756  373508  19  AA
#0 48903756  48903756  373508  62  Aa
#0 48903756  48903756  373508  54  aa

#`/Users/anjathormann/Documents/DEV/ensembl-variation/C_code/calc_genotypes </tmp/ld0005b304000007d8568fbcf2042319c7.in >ld0005b304000007d8568fbcf2042319c7.out`;

my $chr = 3;
my $start = 52_700_000;
my $end   = 52_800_000;
#my $end   = 52787465;

my $population_name = '1000GENOMES:phase_3:GBR';
my $variant_name = 'rs2164983';

my $slice_adaptor = $registry->get_adaptor('human', 'core', 'slice');
my $slice = $slice_adaptor->fetch_by_region('chromosome', $chr, $start, $end);

my $vca = $registry->get_adaptor('human', 'variation', 'vcfcollection');
my $pa = $registry->get_adaptor('human', 'variation', 'population');
my $population = $pa->fetch_by_name($population_name);
my $population_id = $population->dbID;

my $fh = FileHandle->new('/Users/anjathormann/Documents/DEV/work/api/ld_input', 'w');
my $current_sample_id = 1;

my @genotypes = ();
my $sample_names = {};

foreach my $vc (@{$vca->fetch_all}) {
  my %sample_dbID_name = map {$_->dbID => ($_->{_raw_name} || $_->name)} @{$vc->get_all_Samples()};
  foreach my $dbID (keys %sample_dbID_name) {
    my $name = $sample_dbID_name{$dbID};
    $sample_names->{$name} = 1;
  }
  my $vc_genotypes = $vc->_get_all_LD_genotypes_by_Slice_DEV($slice, $population);
  push @genotypes, $vc_genotypes;
}

print scalar @genotypes, "\n";
print scalar keys %$sample_names, "\n";

my $name2dbID = {};
my $current_id = 1;
foreach my $name (keys %$sample_names) {
  $name2dbID->{$name} = $current_id;
  $current_id++;
}

my $vc_genotypes = $genotypes[0];
foreach my $position (keys %$vc_genotypes) {
  foreach my $sample_name (keys %{$vc_genotypes->{$position}}) {
    my $sample_id = $name2dbID->{$sample_name};
    my $gt = $vc_genotypes->{$position}->{$sample_name};
    print $fh "0\t$position\t$position\t$population_id\t$sample_id\t$gt\n";
  }
}


$fh->close();

`/Users/anjathormann/Documents/DEV/ensembl-variation/C_code/calc_genotypes <ld_input >ld_output`;


=begin
my $chr = 3;
my $start = 52786465;
my $end   = 52787465;
my $population_name = '1000GENOMES:phase_3:GBR';
my $variant_name = 'rs2164983';

my $slice_adaptor = $registry->get_adaptor('human', 'core', 'slice');
my $slice = $slice_adaptor->fetch_by_region('chromosome', $chr, $start, $end);

my $vca = $registry->get_adaptor('human', 'variation', 'vcfcollection');
my $pa = $registry->get_adaptor('human', 'variation', 'population');
my $population = $pa->fetch_by_name($population_name);
my $ldFeatureContainerAdaptor = $registry->get_adaptor('human', 'variation', 'ldfeaturecontainer');
$ldFeatureContainerAdaptor->db->use_vcf(2);

sub run_API_code {
  my $ldFeatureContainer = $ldFeatureContainerAdaptor->fetch_by_Slice($slice, $population);
}

=end
=cut
