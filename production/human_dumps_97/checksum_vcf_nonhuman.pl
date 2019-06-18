use strict;
use warnings;

use FileHandle;

my $dir = '/hps/nobackup2/production/ensembl/anja/release_97/dumps/vertebrates/vcf/';

my $all_species = {};

opendir(DIR, $dir) or die $!;
while (my $species = readdir(DIR)) {
  next if ($species =~ /^\./);
  next if ($species ne 'homo_sapiens');
  $all_species->{$species} = 1;
}
closedir(DIR);

compute_checksums($dir, $all_species);


sub run_cmd {
  my $cmd = shift;
  if (my $return_value = system($cmd)) {
    $return_value >>= 8;
    die "system($cmd) failed: $return_value";
  }
}
sub compute_checksums {
  my ($data_dir, $all_species) = @_;
  foreach my $species (keys %$all_species) {
    print STDERR $species, "\n";
    my $working_dir = "$data_dir/$species/";
    opendir(my $dh, $working_dir) or die "Cannot open directory $working_dir";
    my @files = sort {$a cmp $b} readdir($dh);
    closedir($dh) or die "Cannot close directory $working_dir";
    my @checksums = ();
    foreach my $file (@files) {
      next if $file =~ /^\./;
      next if $file =~ /^CHECKSUM/;
      my $path = File::Spec->catfile($working_dir, $file);
      my $checksum = checksum($path);
      push(@checksums, [$checksum, $file]);
    }
    my $fh = FileHandle->new("$working_dir/CHECKSUMS", 'w');
    foreach my $entry (@checksums) {
      my $line = join("\t", @{$entry});
      print $fh $line, "\n";
    }
    $fh->close();
  }
}

sub checksum {
  my $path = shift;
  my $checksum = `sum $path`;
  $checksum =~ s/\s* $path//xms;
  chomp($checksum);
  return $checksum;
}

