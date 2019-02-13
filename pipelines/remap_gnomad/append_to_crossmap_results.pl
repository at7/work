use strict;
use warnings;

use FileHandle;

my $grch38_mappings = '/hps/nobackup2/production/ensembl/anja/gnomad/Exomes/mapping_results/';
my $grch38_ensembl_mappings = '/hps/nobackup2/production/ensembl/anja/release_96/human/remap_gnomad/exomes/unique_mappings/';

my $chrom = $ENV{'LSB_JOBINDEX'};
if ($chrom == 23) {
  $chrom = 'X';
}
if ($chrom == 24) {
  $chrom = 'Y';
}

my $vcf_file = $grch38_mappings . "gnomad.exomes.r2.1.sites.grch38.chr$chrom\_noVEP.vcf";

print STDERR "gunzip $vcf_file.gz\n";

run_cmd("gunzip $vcf_file.gz");

open(my $vcf_fh, '>>', $vcf_file) or die "Could not open file '$vcf_file' $!";

my $fh = FileHandle->new("$grch38_ensembl_mappings/$chrom.vcf", 'r');
while (<$fh>) {
  print $vcf_fh $_;
}

$fh->close;
close $vcf_fh;

my $cmd = "vcf-sort < $vcf_file | bgzip > $vcf_file.gz";

print STDERR "$cmd\n";

run_cmd($cmd);

print STDERR "tabix $vcf_file.gz\n";

run_cmd("tabix $vcf_file.gz");

run_cmd("rm $vcf_file");

sub run_cmd {
  my $cmd = shift;
  if (my $return_value = system($cmd)) {
    $return_value >>= 8;
    die "system($cmd) failed: $return_value";
  }
}

