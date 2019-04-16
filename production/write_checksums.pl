use strict;
use warnings;

use FileHandle;


my $working_dir = "/nfs/production/panda/ensembl/variation/data/gnomAD/v2.1/grch38/genomes/";
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


sub checksum {
    my $path = shift;
    my $checksum = `sum $path`;
    $checksum =~ s/\s* $path//xms;
    chomp($checksum);
    return $checksum;
}


