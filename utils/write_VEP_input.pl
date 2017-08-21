use strict;
use warnings;

use FileHandle;
use Compress::Zlib;

my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/ExAC/end_first_matched_variant_ids', 'r');

my $variant_ids =  {};

while (<$fh>) {
  chomp;
  my @ids = split/,/;
  foreach my $id (@ids) {
    if ($id =~ /^rs/) {
      $variant_ids->{$id} = 1;
    }
  }
}
$fh->close;


my $vcf_file = '/hps/nobackup/production/ensembl/anja/release_90/dumps_human_37/Homo_sapiens.vcf.gz';

my $fh_out = FileHandle->new('/hps/nobackup/production/ensembl/anja/ExAC/end_first_match.vcf', 'w');

my $vcf_fh = gzopen($vcf_file, "rb") or die "Error reading $vcf_file: $gzerrno\n";

while ($vcf_fh->gzreadline($_) > 0) {
  chomp;
  if (/^#/) {
    print $fh_out $_, "\n";  
    next;
  }

  my @values = split/\t/;
 
  if ($variant_ids->{$values[2]})  {
    print $fh_out $_, "\n";
  }
}
$vcf_fh->gzclose(); 
$fh_out->close;

