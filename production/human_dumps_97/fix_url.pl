use strict;
use warnings;

my $dir = '/hps/nobackup2/production/ensembl/anja/release_97/human/dumps/vertebrates/gvf/homo_sapiens/';

opendir(DIR, $dir) or die $!;
while (my $filename_gz = readdir(DIR)) {
  if ($filename_gz =~ m/\.gz$/) {
    my $filename = $filename_gz;
    $filename =~ s/\.gz//;  
    my $file = "$dir/$filename";
    my $file_gz = "$dir/$filename_gz";
    run_cmd("gunzip $file_gz");
    run_cmd("sed -i 's#http://vertebrates.ensembl#https://ensembl#' $file");
    run_cmd("gzip $file");
    print STDERR "$file\n";
  }
}
closedir(DIR);


#my $file = "$dir/homo_sapiens_incl_consequences-chr2.gvf";
#my $file_gz = "$dir/homo_sapiens_incl_consequences-chr2.gvf.gz";
#run_cmd("gunzip $file_gz");
#run_cmd("sed -i 's#http://vertebrates.ensembl#https://ensembl#' $file");
#sed '0,/RE/s//to_that/' file
#run_cmd("sed -i '0,#http://vertebrates.ensembl#s##https://ensembl#' $file");


sub run_cmd {
  my $cmd = shift;
  if (my $return_value = system($cmd)) {
    $return_value >>= 8;
    die "system($cmd) failed: $return_value";
  }
}

