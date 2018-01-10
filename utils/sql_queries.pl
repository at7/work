use strict;
use warnings;

use DBI;
my $dbh = DBI->connect('dbi:mysql:mus_musculus_variation_91_38:mysql-ens-var-prod-2:4521', 'ensro', '', undef);

my $sth = $dbh->prepare(qq{
  SELECT s.sample_id, s.name, s.description, p.population_id, p.name, p.description
  FROM sample s LEFT JOIN sample_population sp
  ON s.sample_id = sp.sample_id
  LEFT JOIN population p
  ON sp.population_id = p.population_id
}, {mysql_use_result => 1});

$sth->execute();
while (my $row = $sth->fetchrow_arrayref) {
  my ($sample_id, $sample_name, $sample_description, $population_id, $population_name, $population_description) = @$row;

  if (!$sample_description && $population_name) {
    $sample_description = "Sample of $population_name";
    print "UPDATE sample set description='$sample_description' where sample_id=$sample_id;\n";
  }

}
$sth->finish();




