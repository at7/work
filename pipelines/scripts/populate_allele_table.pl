use strict;
use warnings;
use DBI;
use Bio::EnsEMBL::Registry;
use FileHandle;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup/production/ensembl/anja/release_91/pig/remapping_genotype_chip/ensembl.registry.oldasm');
my $vdba = $registry->get_DBAdaptor('pig', 'variation');

my $dbh = $vdba->dbc->db_handle();

my $dbh = $vdba->dbc->db_handle();
my $sth = $dbh->prepare(qq{
  SELECT variation_id, allele_string FROM variation_feature_axiom_chip_mapping_results_111;
}, {mysql_use_result => 1});

my $variants = {};
$sth->execute() or die $sth->errstr;
while (my $row = $sth->fetchrow_arrayref) {
  $variants->{$row->[0]} = $row->[1];
}
$sth->finish;

my $allele2code = {
  'A' => 2,
  'C' => 4,
  'G' => 3,
  'T' => 1,
};

foreach my $variant_id (keys %$variants) {
  foreach my $allele (split/\//, $variants->{$variant_id}) {
    my $allele_code = $allele2code->{$allele};
    $dbh->do(qq{INSERT INTO allele_axiom_chip_111(variation_id, allele_code_id) VALUES($variant_id, $allele_code)});
  }
}


