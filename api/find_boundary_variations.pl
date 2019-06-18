use strict;
use warnings;

use Bio::EnsEMBL::Registry;


my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_97/human/regulation_effect/ensembl.registry');

my $species = 'human';

my $sa = $registry->get_adaptor($species, 'core', 'slice');
my $rfa = $registry->get_adaptor($species, 'funcgen', 'RegulatoryFeature');
my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $dbh = $vdba->dbc->db_handle;

#{"seq_region_end" => 44599149,"seq_region_name" => 10,"seq_region_start" => 39643689}
#{"seq_region_end" => 29384982,"seq_region_name" => 17,"seq_region_start" => 24487486}
#{"seq_region_end" => 53970840,"seq_region_name" => 5,"seq_region_start" => 49064401}
my $seq_region_name = 10;
my $seq_region_start = 39643689;
my $seq_region_end = 44599149;
my $slice = $sa->fetch_by_region('toplevel', $seq_region_name, $seq_region_start, $seq_region_end);
my @regulatory_features = grep { $_->seq_region_end <= $seq_region_end  } @{$rfa->fetch_all_by_Slice($slice)||[]};

foreach my $regulatory_feature (@regulatory_features) {
  my $stable_id = $regulatory_feature->stable_id;

  my $sth = $dbh->prepare(qq{
    SELECT COUNT(distinct variation_feature_id) FROM regulatory_feature_variation WHERE feature_stable_id=?;
  });
  $sth->execute($stable_id) or die 'Could not execute statement ' . $sth->errstr;
  my @row = $sth->fetchrow_array;
  my $count = $row[0];
  $sth->finish();

  $slice = $sa->fetch_by_Feature($regulatory_feature);
  my @vfs = ();
  push @vfs, @{ $slice->get_all_VariationFeatures };
  push @vfs, @{ $slice->get_all_somatic_VariationFeatures };

  my $count_vfs = scalar @vfs;
  if ($count_vfs != $count) {
    print STDERR $stable_id, ' ', $count, ' ', $count_vfs, "\n";
    my @sorted = sort {$a->seq_region_end <=> $b->seq_region_end} @vfs;
    my $smallest = $sorted[0];
    my $largest = $sorted[$#sorted];
    print STDERR $smallest->seq_region_start, ' ', $smallest->seq_region_end, "\n";
    print STDERR $largest->seq_region_start, ' ', $largest->seq_region_end, "\n";
  }
}
