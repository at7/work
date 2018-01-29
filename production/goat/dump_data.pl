use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup/production/ensembl/anja/release_92/goat/variation_qc/ensembl.registry');

my $dbh = $registry->get_DBAdaptor('goat', 'variation')->dbc->db_handle;

my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/goat/ssid_2_variation_feature', 'w');
#my $fh_missmatch = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/goat/ssid_2_variant_id_allele_strings_missmatch', 'w');

my $count_by_seq_region = {};
#  SELECT variation_id, name FROM vcf_variation WHERE variation_id != 0;
my $sth = $dbh->prepare(qq{
  SELECT v.variation_id, v.name, v.allele_string, vf.allele_string, vf.map_weight, vf.display, vf.variation_name, sr.name, vf.seq_region_start, vf.seq_region_end 
  FROM vcf_variation v
  LEFT JOIN variation_feature vf on v.variation_id = vf.variation_id
  LEFT JOIN seq_region sr on vf.seq_region_id = sr.seq_region_id
  WHERE v.variation_id != 0;
}, {mysql_use_result => 1});

$sth->execute();
my ($variation_id, $subsnp_id, $vcf_allele_string, $vf_allele_string, $vf_map_weight, $vf_display, $vf_variation_name, $seq_region, $vf_start, $vf_end);
$sth->bind_columns(\($variation_id, $subsnp_id, $vcf_allele_string, $vf_allele_string, $vf_map_weight, $vf_display, $vf_variation_name, $seq_region, $vf_start, $vf_end));
while ($sth->fetch) {
  $variation_id //= 'NA';
  $subsnp_id //= 'NA';
  $vcf_allele_string //= 'NA';
  $vf_allele_string //= 'NA';
  $vf_map_weight //= 'NA';
  $vf_display //= 'NA';
  $vf_variation_name //= 'NA';
  $seq_region //= 'NA';
  $vf_start //= 'NA';
  $vf_end //= 'NA';
  $count_by_seq_region->{$seq_region}++;
#  if ($vcf_allele_string ne $vf_allele_string || ($vf_map_weight > 1 || $vf_map_weight < 1)) {
  print $fh join("\t", $variation_id, $subsnp_id, $vcf_allele_string, $vf_allele_string, $vf_map_weight, $vf_display, $vf_variation_name, $seq_region, $vf_start, $vf_end), "\n";
#  } else {
#    print $fh join("\t", $variation_id, $subsnp_id, $vcf_allele_string, $vf_allele_string, $vf_map_weight), "\n";
#  }
}
$sth->finish;

$fh->close;

foreach my $name (keys %$count_by_seq_region) {
  print STDERR $name, " ", $count_by_seq_region->{$name}, "\n"; 
}

#$fh_missmatch->close;

