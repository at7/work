use strict;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

my $file = '/hps/nobackup/production/ensembl/anja/release_88/chicken/variation_consequence/ensembl.registry';

$registry->load_all($file);
#$registry->load_registry_from_db(-host => 'ensembldb.ensembl.org', -user => 'anonymous');





my $species = 'chicken';

my $vfa = $registry->get_adaptor($species, 'variation', 'variationfeature');
my $sa = $registry->get_adaptor($species, 'core', 'slice');
my $ta = $registry->get_adaptor($species, 'core', 'transcript');

my $gene_adaptor = $registry->get_adaptor($species, 'core', 'gene');


my $gene = $gene_adaptor->fetch_by_stable_id('ENSGALG00000003365');
print $gene->stable_id, "\n";

=begin
# get a slice for the new feature to be attached to
my $slice = $sa->fetch_by_region('LRG', 'LRG_190');

# create a new VariationFeature object
my $new_vf = Bio::EnsEMBL::Variation::VariationFeature->new(
  -start => 17739,
  -end => 17739,
  -slice => $slice,           # the variation must be attached to a slice
  -allele_string => 'G/A',    # the first allele should be the reference allele
  -strand => 1,
  -map_weight => 1,
  -adaptor => $vfa,           # we must attach a variation feature adaptor
  -variation_name => 'newSNP',
);

# get the consequence types

foreach my $con(@{$new_vf->get_all_TranscriptVariations()}) {
  foreach my $string(@{$con->consequence_type}) {
    print
      "Variation ", $new_vf->variation_name,
      " at position ", $new_vf->seq_region_start,
      " on chromosome ", $new_vf->seq_region_name,
      " has consequence ", $string,
      " in transcript ", $con->transcript->stable_id, "\n";
  }
}
=end
=cut
