use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;

my $fh = FileHandle->new("/hps/nobackup2/production/ensembl/anja/vep_data/input/grch37/vep_cache_test_chr12.txt", 'w');

my $registry = 'Bio::EnsEMBL::Registry';
my $file = '/hps/nobackup2/production/ensembl/anja/release_96/human/GRCh37/vep_dumps/ensembl.registry';

$registry->load_all($file);

my $slice_adaptor = $registry->get_adaptor('human', 'core', 'slice');
#my @slices = grep { $_->seq_region_name eq "12" } @{$slice_adaptor->fetch_all('chromosome')};
my @slices = @{$slice_adaptor->fetch_all('chromosome')};


my $vdba = $registry->get_DBAdaptor('human', 'variation');
my $dbh = $vdba->dbc->db_handle;

foreach my $slice (@slices) {
  my $seq_region_name = $slice->seq_region_name;
  my $seq_region_id = $slice->get_seq_region_id;
  # 1 182712 182712 A/C 1
  my $sth = $dbh->prepare(qq{
    SELECT seq_region_start, seq_region_end, allele_string, 1, variation_name from variation_feature
    WHERE seq_region_id = ?
    AND source_id = 1 
    AND map_weight = 1
    AND display = 1
    LIMIT 10000;
  });
  $sth->execute($seq_region_id);
  while (my $row = $sth->fetchrow_arrayref) {
    print $fh $seq_region_name, "\t", join("\t", @$row), "\n";
  }
  $sth->finish();
}

$fh->close;

