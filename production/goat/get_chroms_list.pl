use strict;
use warnings;


my $output = `tabix --list-chroms /hps/nobackup2/production/ensembl/anja/release_95/cow/remapping_vcf/IRBT.population_sites.UMD3_1.20140322_EVA_ss_IDs.vcf.gz`;

my @chroms = split/\n/, $output;
print scalar @chroms, "\n";

foreach (@chroms) {
  print $_, "\n";
}



