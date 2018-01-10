use strict;
use warnings;


use DBI;
use Bio::EnsEMBL::Registry;
use FileHandle;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup/production/ensembl/anja/release_91/pig/remapping_genotype_chip/ensembl.registry.oldasm');
my $vdba = $registry->get_DBAdaptor('pig', 'variation');

my $dbh = $vdba->dbc->db_handle();

# updates
my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_91/pig/remapping_genotype_chip/qc_failure_reasons/1.txt', 'r');


while (<$fh>) {
  chomp;
  my ($variation_id, $failed_description_id) = split/\s/;
  $dbh->do(qq{INSERT INTO failed_variation_axiom_chip_91(variation_id, failed_description_id) VALUES($variation_id, $failed_description_id)});
  print "$variation_id, $failed_description_id\n";
}


#while (<$fh>) {
#  chomp;
#  $dbh->do($_);
#}


$fh->close;

