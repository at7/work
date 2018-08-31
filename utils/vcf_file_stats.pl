use strict;
use warnings;

use FileHandle;
use File::Path qw(make_path);
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

my $working_dir = '/nfs/production/panda/ensembl/variation/data/1kg/updated_20170504/';

tabix_vcf_files();
my $total_count = 0;
sub tabix_vcf_files {
  next unless (-d $working_dir);
  opendir(DIR, $working_dir) or die $!;
  while (my $file = readdir(DIR)) {
    if ($file =~ m/\.vcf.gz$/) {
      my $value =  `bcftools index --nrecords $working_dir/$file`;
      chomp $value;
      $total_count += $value;
    }
  }
  closedir(DIR);
  print STDERR "$total_count\n";
}

