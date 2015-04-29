use strict;
use warnings;

require "../utils/db.pl";

use Getopt::Long;

# perl individuals.pl -db_config db_config

my $config = {};

GetOptions(
  $config,
  'db_config=s',
  'mode=s',
) or die "Error: Failed to parse command line arguments\n";

die ('A db_config file is required (--db_config)') unless (defined($config->{db_config}));

if ($config->{mode} eq 'create_samples') {
  create_samples();
}


sub test_new_schema {


}


sub create_samples {
  my $individuals = {};
  my $is_sample = {};
  my $dbh = get_dbh($config->{db_config});  
  my $stmt = qq{SELECT individual_id, name, description FROM individual;};

  my $sth = $dbh->prepare($stmt) or die $dbh->errstr;
  $sth->execute() or die $sth->errstr;
  while (my $row = $sth->fetchrow_arrayref) {
    my @values = map { defined $_ ? $_ : '\N' } @$row;
    my $individual_id = $values[0];
    my $name = $values[1];
    my $description = $values[2];
    $individuals->{$name}->{$individual_id} = $description;
  }
  $sth->finish();
 
  foreach my $name (keys %$individuals) {
    if (scalar keys %{$individuals->{$name}} > 1) {
      $dbh->do(qq{INSERT INTO individual(name) VALUES('$name');}) or die $dbh->errstr;
      my $individual_id = $dbh->last_insert_id(undef, undef, 'individual', 'individual_id');
      foreach my $sample_id (keys %{$individuals->{$name}}) {
        $dbh->do(qq{UPDATE individual SET is_sample=1 WHERE individual_id=$sample_id;}) or die $dbh->errstr;
        $dbh->do(qq{INSERT INTO individual_sample(individual_id, sample_id) VALUES($individual_id, $sample_id);});
      }
    } 
  } 
}
