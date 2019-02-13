use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_96/human/remap_gnomad/genomes/ensembl.registry');
my $dbh = $registry->get_DBAdaptor('human', 'variation')->dbc->db_handle;

my $write_multi_mapping_results = 0;
if ($write_multi_mapping_results) {
  my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_96/human/remap_gnomad/genomes/multi_mapping_results.txt', 'w');
  my $sth = $dbh->prepare(qq{
    SELECT sr.name, vf.seq_region_id, vf.seq_region_start, vf.seq_region_end, vf.allele_string, vf.variation_name, vf.variation_id, sr37.name, brvf.seq_region_start, brvf.seq_region_end, brvf.allele_string
    FROM seq_region sr, seq_region_37 sr37, variation_feature vf, before_remapping_variation_feature brvf
    WHERE vf.variation_id = brvf.variation_id
    AND vf.seq_region_id = sr.seq_region_id
    AND brvf.seq_region_id = sr37.seq_region_id
    AND vf.map_weight > 1;
  });
  $sth->execute();
  while (my $row = $sth->fetchrow_arrayref) {
    print $fh join("\t", @$row), "\n";
  }
  $sth->finish();
  $fh->close();
}

my $write_unique_results = 1;
# write mapping results with map weight 1 to file
if ($write_unique_results) {
  foreach my $chrom (1..22,'X','Y','MT') {
    my $fh = FileHandle->new("/hps/nobackup2/production/ensembl/anja/release_96/human/remap_gnomad/genomes/unique_mappings/chrom$chrom.txt", 'w');
    my $sth = $dbh->prepare(qq{
      SELECT sr.name, vf.seq_region_id, vf.seq_region_start, vf.seq_region_end, vf.allele_string, vf.variation_name, vf.variation_id, sr37.name, brvf.seq_region_start, brvf.seq_region_end, brvf.allele_string
      FROM seq_region sr, seq_region_37 sr37, variation_feature vf, before_remapping_variation_feature brvf
      WHERE vf.variation_id = brvf.variation_id
      AND vf.seq_region_id = sr.seq_region_id
      AND brvf.seq_region_id = sr37.seq_region_id
      AND vf.map_weight = 1
      AND sr.name = ?;
    });
    $sth->execute($chrom);
    while (my $row = $sth->fetchrow_arrayref) {
      print $fh join("\t", @$row), "\n";
    }
    $sth->finish();
    $fh->close();
  }
}
