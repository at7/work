use strict;
use warnings;

use FileHandle;

# analysis_accession  study_accession sample_accession  secondary_sample_accession  tax_id  scientific_name submitted_ftp submitted_galaxy
my $fh = FileHandle->new('/nfs/production/panda/ensembl/variation/data/sheep/ISGC/PRJEB14685.txt', 'r');

my $wget = 0;

if ($wget) {
while (<$fh>) {
  chomp;
  next if (/^analysis_accession/);
  my @values = split/\t/;
  my @ftp_files = split(';', $values[6]);
  my ($vcf_file) = grep {$_ =~ /vcf\.gz$/} @ftp_files;
  my $out = `wget -P /nfs/production/panda/ensembl/variation/data/sheep/ISGC/ 'ftp://$vcf_file'`;
  print STDERR $out, "\n";
}
$fh->close;
}
