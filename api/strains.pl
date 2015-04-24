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

my $sa = $reg->get_adaptor("mouse", "core", "slice");
my $slice = $sa->fetch_by_region('chromosome', 19, 20380186, 20384187);

# get strainSlice from the slice
my $mouse_strain = $slice->get_by_strain("A/J");
my @differences = @{$mouse_strain->get_all_AlleleFeatures_Slice()};
foreach my $diff (@differences){
  print "Locus ", $diff->seq_region_start, "-", $diff->seq_region_end, ", A/J's alleles: ",$diff->allele_string, "\n";
}

my $genes = $mouse_strain->get_all_Genes();
while ( my $gene = shift @{$genes} ) {
  my $gene_string = feature2string($gene);
  print "$gene_string\n";
}

sub feature2string{
  my $feature = shift;
  my $stable_id  = $feature->stable_id();
  my $seq_region = $feature->slice->seq_region_name();
  my $start      = $feature->start();
  my $end        = $feature->end();
  my $strand     = $feature->strand();
  return sprintf( "%s: %s:%d-%d (%+d)",
      $stable_id, $seq_region, $start, $end, $strand );
}
