use strict;
use warnings;

use FileHandle;
use DBI;
my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_91/sheep/dbsnp_snpbatch_1059595.txt', 'r');
# ss836367750     s76022.1        C/T     12      rs415313175     +       6       98062051        NW_014639015.1  98062051
my $dbh = DBI->connect('dbi:mysql:ovis_aries_SNP50_HDSNP_31:mysql-ens-var-prod-2.ebi.ac.uk:4521', 'ensadmin', 'ensembl', undef);

while (<$fh>) { 
  chomp;
  if (/^ss/) {
    my @values = split/\s+/;
    my $ssid = $values[0];
    $ssid =~ s/ss//;
    my $chip_name = $values[1];
    my $allele_string = $values[2];
    my $rsid = $values[4];
    $dbh->do(qq{INSERT INTO variation_SNP50(subsnp_id, variation_synonym, allele_string, variation_name) VALUES($ssid, '$chip_name', '$allele_string', '$rsid');});
  }
}


$fh->close();
