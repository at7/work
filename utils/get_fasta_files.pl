
my $dir = '/hps/nobackup/production/ensembl/anja/release_91/chimpanzee/remapping/new_assembly';
opendir(my $dh, $dir) || die "Can't opendir $dir: $!";
my @files = grep { /\.fa$/ } readdir($dh);
closedir $dh;
print $files[0], "\n";

