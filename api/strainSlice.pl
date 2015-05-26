use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
);

my $sa = $registry->get_adaptor('human', 'core', 'slice');

my $slice = $sa->fetch_by_region( 'chromosome', '1', 1_000_000, 1_500_000 );

my $strain_name = 'VENTER';
my $strainSlice = $slice->get_by_strain($strain_name);

# get allele features between this StrainSlice and the reference
my $afs = $strainSlice->get_all_AlleleFeatures_Slice();
foreach my $af ( @{$afs} ) {
  print "AlleleFeature in position ", $af->start, "-", $af->end, " in strain with allele ", $af->allele_string, "\n";
}

# compare a strain against another strain
my $strain_name_2 = 'WATSON';

my $strainSlice_2 = $slice->get_by_strain($strain_name_2);
my $differences = $strainSlice->get_all_differences_StrainSlice($strainSlice_2);
foreach my $difference ( @{$differences} ) {
  print "Difference in position ", $difference->start, "-", $difference->end(), " in strain with allele ", $difference->allele_string(), "\n";
}
#$strainSlice-> get_all_AlleleFeatures_Slice()
