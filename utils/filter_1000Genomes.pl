use strict;
use warnings;

use FileHandle;
use Compress::Zlib;

my $vcf_file = '/hps/nobackup/production/ensembl/anja/release_90/dumps_90/vcf/homo_sapiens/1000GENOMES-phase_3.vcf.gz';

my $fh_out = FileHandle->new('/hps/nobackup/production/ensembl/anja/1000Genomes_chr10_insertions.vcf', 'w');
my $fh_in = gzopen($vcf_file, "rb") or die "Error reading $vcf_file: $gzerrno\n";


while ($fh_in->gzreadline($_) > 0) {
  chomp;
  if (/^#/) {
    print $fh_out $_, "\n";        
  } else {
    if (/^10/ && m/insertion/) {
      print $fh_out $_, "\n";        
    }
  }
}


$fh_in->gzclose();
$fh_out->close();
