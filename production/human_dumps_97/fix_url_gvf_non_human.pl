use strict;
use warnings;


my $dir = '/hps/nobackup2/production/ensembl/anja/release_97/dumps/vertebrates/gvf/';

opendir(DIR, $dir) or die $!;
while (my $species = readdir(DIR)) {
  next if ($species =~ /^\./);
  my $species_dir = $dir . $species;
  print STDERR $species_dir, "\n";
  opendir(SPECIES_DIR, $species_dir) or die $!;
  while (my $filename_gz = readdir(SPECIES_DIR)) {
    if ($filename_gz =~ m/\.gz$/) {
      my $filename = $filename_gz;
      $filename =~ s/\.gz//;
      my $file = "$species_dir/$filename";
      my $file_gz = "$species_dir/$filename_gz";
      run_cmd("gunzip $file_gz");
      run_cmd("sed -i 's#http://vertebrates.ensembl#https://ensembl#' $file");
      run_cmd("gzip $file");
      print STDERR "$file\n";
    } 
  }
  closedir(SPECIES_DIR);
}
closedir(DIR);

sub run_cmd {
  my $cmd = shift;
  if (my $return_value = system($cmd)) {
    $return_value >>= 8;
    die "system($cmd) failed: $return_value";
  }
}

