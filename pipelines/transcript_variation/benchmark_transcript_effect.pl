use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
my $file = '/hps/nobackup2/production/ensembl/anja/release_96/human/transcript_variation/ensembl.registry';
$registry->load_all($file);

my $transcript_adaptor = $registry->get_adaptor('human', 'core', 'transcript');

my $ga = $registry->get_adaptor('human', 'core', 'gene');
my $sa = $registry->get_adaptor('human', 'core', 'slice');

my $vfa = $registry->get_adaptor('human', 'variation', 'variationfeature');

# we need to include failed variations
$vfa->db->include_failed_variations(1);

my $gene_id = 'ENSG00000078328';
my $max_distance = 0;

my $gene = $ga->fetch_by_stable_id($gene_id)
  or die "failed to fetch gene for stable id: $gene_id";

my $slice = $sa->fetch_by_gene_stable_id(
  $gene_id,
  $max_distance
) or die "failed to get slice around gene: $gene_id";

# call seq here to help cache
$slice->seq();

$gene = $gene->transfer($slice);

my @vfs = (
  @{ $vfa->fetch_all_by_Slice_SO_terms($slice) },
  @{ $vfa->fetch_all_somatic_by_Slice_SO_terms($slice) }
);

print STDERR scalar @vfs, "\n";


