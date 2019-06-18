use strict;
use warnings;

my $dir = '/hps/nobackup2/production/ensembl/anja/release_97/dumps/vertebrates/vcf/';

opendir(DIR, $dir) or die $!;
while (my $species = readdir(DIR)) {
  next if ($species =~ /^\./);
  next if ($species eq 'monodelphis_domestica');
  my $species_dir = $dir . $species;
  print STDERR $species_dir, "\n";
  opendir(SPECIES_DIR, $species_dir) or die $!;
  while (my $filename = readdir(SPECIES_DIR)) {
    if ($filename =~ m/\.vcf$/) {
      my $filename_gz = "$filename.gz";
      my $file = "$species_dir/$filename";
      my $file_gz = "$species_dir/$filename_gz";
      run_cmd("vcf-sort -t /hps/nobackup2/production/ensembl/anja/ < $file | bgzip > $file_gz");
      run_cmd("tabix -f -p vcf $file_gz");
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

