use strict;
use warnings;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Variation::Utils::FastaSequence qw(setup_fasta);


my $registry = 'Bio::EnsEMBL::Registry';

my $file = '/gpfs/nobackup/ensembl/anja/release_88/sheep/variation_consequence/ensembl.registry';

$registry->load_all($file);
my $species = 'sheep';
my $csa = $registry->get_adaptor($species, 'core', 'coordsystem');

my $fasta = '/gpfs/nobackup/ensembl/anja/release_88/sheep/variation_consequence/Ovis_aries.Oar_v3.1.dna.toplevel.fa.gz';

my ($highest_cs) = @{$csa->fetch_all()};
my $assembly = $highest_cs->version();

setup_fasta(-FASTA => $fasta, -ASSEMBLY => $assembly);
