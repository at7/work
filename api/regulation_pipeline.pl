use strict;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

my $file = '/lustre/scratch110/ensembl/at7/release_85/ensembl.registry';

$registry->load_all($file);

my $vfa = $registry->get_adaptor('human', 'variation', 'variationfeature');
my $sa = $registry->get_adaptor('human', 'core', 'slice');
my $rfa = $registry->get_adaptor('human', 'funcgen', 'regulatoryfeature');
my $mfa = $registry->get_adaptor('human', 'funcgen', 'motiffeature');

my $ga = $registry->get_adaptor('human', 'core', 'gene');

my @genes = @{ $ga->fetch_all };
foreach my $gene (@genes) {
  print STDERR $gene->stable_id, "\n";
}

#my $slices = $sa->fetch_all('toplevel', undef, 0, 1);


#my @feature_ids = ();
#foreach my $slice (@$slices) {

#  my @mfs = @{$mfa->fetch_all_by_Slice($slice)};
#  print scalar @mfs, "\n";



#  my $rfs = $rfa->fetch_all_by_Slice($slice);
#  foreach my $rf (@$rfs) {
#    push @feature_ids, { feature_id => $rf->stable_id,
#                         feature_type => 'regulatory_feature',
#                         species => 'homo_sapiens', };
#  }

#}




