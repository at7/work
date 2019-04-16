use strict;
use warnings;

use FileHandle;
#my $dir = '/hps/nobackup2/production/ensembl/anja/release_94/human/grch37/dumps/vcf/homo_sapiens/';
my $dir = '/hps/nobackup2/production/ensembl/anja/release_96/human/dumps/population_dumps/vcf/homo_sapiens/';

my $fh_out = FileHandle->new("$dir/1000GENOMES-phase_3.vcf", 'w'); 

my $fh_in = FileHandle->new("$dir/1000GENOMES-phase_3_chromY.vcf", 'r');

while (<$fh_in>) {
  chomp;
  if (/^#/) {
    print $fh_out $_, "\n";
  }
}
$fh_in->close;

for my $i (1..22,'X', 'Y') {

  $fh_in = FileHandle->new("$dir/1000GENOMES-phase_3_chrom$i.vcf", 'r');
  while (<$fh_in>) {
    chomp;
    next if /^#/;
    print $fh_out $_, "\n";
  }
  $fh_in->close;
}

$fh_out->close;
