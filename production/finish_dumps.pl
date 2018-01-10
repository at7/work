use strict;
use warnings;

use FileHandle;
use File::Path qw(make_path);
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

my $data_dump_dir = '/hps/nobackup/production/ensembl/anja/release_91/dumps_human/';
my $registry_file = '/hps/nobackup/production/ensembl/anja/release_91/dumps_human/ensembl.registry';
#my $registry_file = '/hps/nobackup/production/ensembl/anja/release_90/dumps_human/ensembl.registry';


$registry->load_all($registry_file);
my $vdbas = $registry->get_all_DBAdaptors(-group => 'variation');

my $all_species = {};
foreach my $vdba (@$vdbas) {
  my $species_name = lc $vdba->species();
  next unless ($species_name eq 'homo_sapiens');
  $all_species->{$species_name} = 1;
}
#tabix_vcf_files($data_dump_dir, $all_species);
compute_checksums($data_dump_dir, $all_species);

sub tabix_vcf_files {
  my ($data_dir, $all_species) = @_;
  foreach my $species (keys %$all_species) {
    my $working_dir = "$data_dir/vcf/$species/";
    next unless (-d $working_dir);
    print STDERR $working_dir, "\n";
    opendir(DIR, $working_dir) or die $!;
    while (my $file = readdir(DIR)) {
      if ($file =~ m/\.vcf$/) {
        my $vcf_file = "$working_dir/$file";
        print STDERR $vcf_file, "\n";
#        system("vcf-sort < $vcf_file | bgzip > $vcf_file.gz");
#        system("rm $vcf_file");
      }
      if ($file =~ m/\.out$/ || $file =~ m/\.err$/) {
        print STDERR "rm $file\n";
#        system("rm $working_dir/$file");
      }
    }
    closedir(DIR);

    opendir(DIR, $working_dir) or die $!;
    while (my $file = readdir(DIR)) {
      if ($file =~ m/\.vcf.gz$/) {
        print STDERR "$working_dir/$file\n";
        system("tabix -f -p vcf $working_dir/$file");
      }
    }
    closedir(DIR);
  }
}


sub compute_checksums {
  my ($data_dir, $all_species) = @_;
#  foreach my $file_type (qw/vcf gvf/) {
  foreach my $file_type (qw/gvf/) {

    foreach my $species (keys %$all_species) {
      print STDERR $species, "\n";
      my $working_dir = "$data_dir/$file_type/$species/";
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
}

sub checksum {
  my $path = shift;
  my $checksum = `sum $path`;
  $checksum =~ s/\s* $path//xms;
  chomp($checksum);
  return $checksum;
}
