use strict;
use warnings;

use FileHandle;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
my $registry_file = '/hps/nobackup2/production/ensembl/anja/release_97/human/ensembl.registry';
$registry->load_all($registry_file);
my $vdba = $registry->get_DBAdaptor('human', 'variation');
my $dbc = $vdba->dbc;

my $file_number = $ENV{'LSB_JOBINDEX'};
my $species_dir = '/hps/nobackup2/production/ensembl/anja/release_97/ancestral_alleles/update_human/';
opendir(my $dh, $species_dir) || die "Can't opendir $species_dir: $!";
my @update_files = sort grep { $_ =~ /\.out$/ } readdir($dh);
my $file = $update_files[$file_number - 1];

print STDERR "$file\n";
my $fh = FileHandle->new("$species_dir/$file", 'r');
while (<$fh>) {
  chomp;
  $dbc->do($_) or die $!;
}
$fh->close;
