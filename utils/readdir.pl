use strict;
use warnings;
my $compara_data = '/hps/nobackup2/production/ensembl/anja/release_97/ancestral_alleles/comapara_data/';
opendir(my $dh, $compara_data) || die "Can't opendir $compara_data: $!";
my @dots = grep { $_ ne '.' and $_ ne '..' } readdir($dh);
closedir $dh;
print @dots, "\n";
