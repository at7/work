use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;
use Getopt::Long;

use Bio::EnsEMBL::Variation::DBSQL::DBAdaptor;

my $config = {};

my $registry = 'Bio::EnsEMBL::Registry';

#mysql -h mysql-ens-var-prod-1.ebi.ac.uk -u ensro -P 4449
my $vdba = new Bio::EnsEMBL::Variation::DBSQL::DBAdaptor(
  -host => 'mysql-ens-var-prod-1.ebi.ac.uk',
  -user => '',
  -pass => '',
  -port => ,
  -dbname => 'homo_sapiens_variation_88_38',
) or die("Could not get VDBA");

my $dbh = $vdba->dbc->db_handle;

my $sth = $dbh->prepare(qq{
Show tables like '%tmp_sample_genotype_single_bp%';
}, {mysql_use_result => 1});

my @tables = ();
$sth->execute();
while (my $row = $sth->fetchrow_arrayref) {
  my $table_name = $row->[0];
  push @tables, $table_name;
}
$sth->finish();


#ALTER TABLE tmp_sample_genotype_single_bp_extra ADD COLUMN `population_id` INT(10) AFTER `sample_id`,

foreach my $table (@tables) {
  next if ($table =~ /BU$/);
  next if ($table eq 'tmp_sample_genotype_single_bp');
  print $table, "\n";
#  my $bu_table = "$table\_BU";
#  $dbh->do("CREATE table $bu_table like $table") or die $dbh->errstr; 
#  $dbh->do("INSERT INTO $bu_table SELECT * FROM $table") or die $dbh->errstr; 

  $dbh->do("DELETE gt FROM $table gt
    LEFT JOIN hapmap_subsnp s ON s.variation_id = gt.variation_id AND s.subsnp_id = gt.subsnp_id
    LEFT JOIN hapmap_sample_population p ON s.population_id = p.population_id AND gt.sample_id = p.sample_id
    WHERE p.sample_id IS NOT NULL;")
}

#$dbh->do(qq/DELETE FROM variation WHERE source_id=$source_id;/) or die  $dbh->errstr;
# show tables like '%tmp_sample_genotype_single_bp%'
#
#
#
#
#
#
#
