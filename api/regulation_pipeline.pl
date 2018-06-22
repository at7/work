use strict;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

my $file = '/hps/nobackup2/production/ensembl/anja/release_93/mouse/regulation_effect/ensembl.registry';

$registry->load_all($file);

my $sa = $registry->get_adaptor('mouse', 'core', 'slice');
my $rfa = $registry->get_adaptor('mouse', 'funcgen', 'regulatoryfeature');
my $mfa = $registry->get_adaptor('mouse', 'funcgen', 'motiffeature');

my $ga = $registry->get_adaptor('mouse', 'core', 'gene');

my $slices = $sa->fetch_all('toplevel', undef, 0, 1);
foreach my $slice (@$slices) {
  print STDERR $slice->seq_region_name, "\n";
  my @mfs = @{$mfa->fetch_all_by_Slice($slice)};
  print STDERR "MFs ", scalar @mfs, "\n";
#  my $rfs = $rfa->fetch_all_by_Slice($slice);
#  if ($rfs) {
#    print STDERR "RFs ", scalar @$rfs, "\n";
#  }
}




