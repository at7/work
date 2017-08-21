use strict;
use warnings;

use DBI;

my @databases1 = qw/
bos_taurus_variation_89_31
canis_familiaris_variation_89_31
danio_rerio_variation_89_10
drosophila_melanogaster_variation_89_6
equus_caballus_variation_89_2
felis_catus_variation_89_62
gallus_gallus_variation_89_5
macaca_mulatta_variation_89_801
meleagris_gallopavo_variation_89_21
monodelphis_domestica_variation_89_5
/;
my @databases2 = qw/
mus_musculus_variation_89_38
nomascus_leucogenys_variation_89_1
ornithorhynchus_anatinus_variation_89_1
ovis_aries_variation_89_31
pan_troglodytes_variation_89_214
pongo_abelii_variation_89_1
rattus_norvegicus_variation_89_6
saccharomyces_cerevisiae_variation_89_4
sus_scrofa_variation_89_102
taeniopygia_guttata_variation_89_1
tetraodon_nigroviridis_variation_89_8/;

my $output_dir = '/hps/nobackup/production/ensembl/anja/release_89/healthchecks/';
my $hc_dir = '';
my $host = 'mysql-ens-var-prod-2.ebi.ac.uk';
my $port = ;
my $user = '';
my $password = '';
my $count = 1;
#foreach my $dbname (@databases1, @databases2) {
#  my $result = `grep Successfully $output_dir/$dbname.out`;
#  if ($result) {
#    system("bsub -J txt2html_$count -o $count.out -e $count.err perl /homes/anja/bin/ensj-healthcheck/healthcheck_txt2html.pl -v 89 -i $output_dir/$dbname.out -o $output_dir/$dbname.html");
#  $count++;
#  }
#}

#foreach my $dbname (@databases2) {
#  system("bsub -J HC_$dbname -o $output_dir/$dbname.out -e $output_dir/$dbname.err bash run-configurable-testrunner.sh -h $host -u ensro -P 4521 -d $dbname -g VariationRelease");
#}

foreach my $dbname (@databases1, @databases2) {
  my $dbh = DBI->connect("DBI:mysql:database=$dbname;host=$host;port=$port;user=$user;password=$password", {RaiseError => 1});
  my $sth = $dbh->prepare(qq{
      SHOW TABLES LIKE '%MTMP%';
  });
  $sth->execute() or die 'Could not execute statement ' . $sth->errstr;
  my ($table);
  $sth->bind_columns(\$table);
  while ($sth->fetch) {
    print STDERR "Drop $table $dbname\n";
    if ($table eq 'MTMP_supporting_structural_variation') {
      print STDERR "$dbname\n";
      $dbh->do(qq{DROP VIEW $table;}) or die $dbh->errstr; 
    }
  }
  $sth->finish();
}
=end
=cut
