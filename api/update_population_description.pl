use strict;
use warnings;
use FileHandle;
use Bio::EnsEMBL::Registry;
use Data::Dumper;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_all('/hps/nobackup/production/ensembl/anja/release_92/sheep/ensembl.registry');

my $species = 'sheep';

my $breed_codes = {};
my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/sheep/breed_code', 'r');
while (<$fh>) {
  chomp;
  next if (/^BreedCode/);
  my @values = split(/\s/, $_, 2);
  $breed_codes->{$values[1]} = $values[0];
}
$fh->close;

my $sample_adaptor = $registry->get_adaptor($species, 'variation', 'sample');
my $individual_adaptor = $registry->get_adaptor($species, 'variation', 'individual');
my $population_adaptor = $registry->get_adaptor($species, 'variation', 'population');

my $vdba = $registry->get_DBAdaptor($species, 'variation');

my $dbh = $vdba->dbc->db_handle;


my $sth = $dbh->prepare(qq/select population_id, name, description from population where name like '%ISGC:%';/);
$sth->execute() or die $sth->errstr;
while (my $row = $sth->fetchrow_arrayref) {
  my $population_id = $row->[0];
  my $name = $row->[1];
  my $description = $row->[2];
#  print STDERR "$population_id $name $description\n";

  $name =~ s/ISGC://g;
  my $breed_code = $breed_codes->{$name};
  if ($breed_code) {
    # new name ISGC:$beed_code, desc; $name population from the  International Sheep Genome Consortium
    $dbh->do(qq{Update population set name="ISGC:$breed_code" where population_id=$population_id;}) or die $dbh->errstr;#
    $dbh->do(qq{Update population set description="$name population from the International Sheep Genome Consortium" where population_id=$population_id;}) or die $dbh->errstr;#
  }

}
$sth->finish;

