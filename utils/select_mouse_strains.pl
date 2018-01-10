use strict;
use warnings;

use DBI;
use FileHandle;

my $dbh = DBI->connect('dbi:mysql:mus_musculus_variation_91_38:mysql-ens-var-prod-2:4521', 'ensro', '', undef);



my $sample_id2name = {};

my $sth = $dbh->prepare(qq{
  SELECT sample_id, name FROM sample;
}, {mysql_use_result => 1});

$sth->execute();
while (my $row = $sth->fetchrow_arrayref) {
  $sample_id2name->{$row->[0]} = $row->[1];
}
$sth->finish();


my $counts = {};

# sample id submitter_handle count of genotypes
#tmp_sample_genotype_single_bp
#  subsnp_id
#  sample_id
#variation_synonym
#  subsnp_id
#  submitter_handle

$sth = $dbh->prepare(qq{
  SELECT sg.subsnp_id, sg.sample_id, vs.submitter_handle
  FROM tmp_sample_genotype_single_bp sg LEFT JOIN variation_synonym vs
  ON sg.subsnp_id = vs.subsnp_id
}, {mysql_use_result => 1});

$sth->execute();
while (my $row = $sth->fetchrow_arrayref) {
  my ($subsnp_id, $sample_id, $submitter_handle) = @$row;
  $counts->{$submitter_handle}->{$sample_id}++;
}
$sth->finish();

foreach my $handle (keys %$counts) {
  foreach my $sample_id (keys %{$counts->{$handle}}) {
    print STDERR "$handle $sample_id ", $sample_id2name->{$sample_id}, " ", $counts->{$handle}->{$sample_id}, "\n";
  }
}

