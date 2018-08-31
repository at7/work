use strict;
use warnings;

use FileHandle;
use File::Path qw(make_path);
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

my $working_dir = '/nfs/production/panda/ensembl/variation/data/1kg/updated_20170504/';

tabix_vcf_files();

sub tabix_vcf_files {
  next unless (-d $working_dir);
  opendir(DIR, $working_dir) or die $!;
  while (my $file = readdir(DIR)) {
    if ($file =~ m/\.vcf.gz$/) {
      print STDERR "$working_dir/$file\n";
      system("tabix -f -p vcf $working_dir/$file");
    }
  }
  closedir(DIR);
}

