use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_96/human/remap_gnomad/genomes/ensembl.registry');
my $dbh = $registry->get_DBAdaptor('human', 'variation')->dbc->db_handle;

my $dir = '/hps/nobackup2/production/ensembl/anja/gnomad/Genomes/mapping_results/';
my $fh = FileHandle->new("$dir/write_gnomad_exomes_unmapped.txt", 'r');

while (<$fh>) {
  chomp;
  my ($seq_region_id, $start, $end, $allele_string, $id) = split/\t/;
  $dbh->do(qq{
    INSERT INTO variation_feature(seq_region_id, seq_region_start, seq_region_end, seq_region_strand, allele_string, variation_name)
    VALUES($seq_region_id, $start, $end, 1, '$allele_string', '$id');
  }) or die $dbh->errstr;
}
$fh->close;
