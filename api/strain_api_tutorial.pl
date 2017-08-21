use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $reg = 'Bio::EnsEMBL::Registry';
my $host= 'ensembldb.ensembl.org';
my $user= 'anonymous';

$reg->load_registry_from_db(
  -host => $host,
  -user => $user
);

my $strain_slice_adaptor = $reg->get_adaptor('mouse', 'variation', 'StrainSlice');
my $slice_adaptor = $reg->get_adaptor("mouse", "core", "slice");

my $slice = $slice_adaptor->fetch_by_region('chromosome', 19, 20380186, 20384187);

$strain_slice_adaptor->db->use_vcf(1);

# get strainSlice from the slice
my $a_j = $strain_slice_adaptor->get_by_strain_Slice("MGP:A/J", $slice);

my @differences = @{$a_j->get_all_AlleleFeatures_Slice(1)};

foreach my $diff (@differences){
  print "Locus ", $diff->seq_region_start, "-", $diff->seq_region_end, ", A/J's alleles: ", $diff->allele_string, "\n";
}
