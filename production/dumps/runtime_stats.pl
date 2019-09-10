use strict;
use warnings;


use DBI;
use JSON;

use Bio::EnsEMBL::Hive::Utils ('stringify', 'destringify');

my $dbh = DBI->connect("DBI:mysql:database=anja_dumps_human_38_98;host=mysql-ens-var-prod-3;port=4606", "ensro", "", {'RaiseError' => 1});

my $sth = $dbh->prepare("
  SELECT
    j.`runtime_msec`,
    d.`data`
  FROM job j
    LEFT JOIN analysis_data d ON j.input_id=concat('_extended_data_id ',d.analysis_data_id)
    where j.analysis_id=13;
") || die "Error:" . $dbh->errstr . "\n";

$sth->execute ||  die "Error:" . $sth->errstr . "\n";

while (my $ref = $sth->fetchrow_arrayref) {
  next unless ($ref->[0] && $ref->[1]);
  my $msec = $ref->[0];
  my $h = $msec / 3.6e+6; 
  my $data = destringify $ref->[1];
  if ($h > 12) {
    my $d = $h / 24;
    print $d . ' ' . $data->{vcf_file}, "\n";
  }
#  print join(' ', keys %$data ), "\n";
}
