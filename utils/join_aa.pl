use strict;
use warnings;

use FileHandle;
use ImportUtils qw(load);
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
my $registry_file = '/hps/nobackup2/production/ensembl/anja/release_98/ancestral_alleles/ensembl.registry';
$registry->load_all($registry_file);
my $vdba = $registry->get_DBAdaptor('homo_sapiens', 'variation');
my $dbc = $vdba->dbc;

my $species_dir = '/hps/nobackup2/production/ensembl/anja/release_98/ancestral_alleles/homo_sapiens/';
opendir(my $dh, $species_dir) || die "Can't opendir $species_dir: $!";
my @update_files = sort grep { $_ =~ /\.out$/ } readdir($dh);

my $out = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_98/ancestral_alleles/aa_new_dbsnp', 'w');
foreach my $file (@update_files) {
  my $fh = FileHandle->new("$species_dir/$file", 'r');
  while (<$fh>) {
    chomp;
    my $line = $_;
    $line =~ s/UPDATE variation_feature SET ancestral_allele='|' WHERE variation_feature_id|;//g;
    my ($aa, $vf_id) = split('=', $line);
    print $out "$vf_id\t$aa\n";
  }
  $fh->close;
}

$out->close;



