use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(-host => 'ensembldb.ensembl.org', -user => 'anonymous');

if (0) {
use FileHandle;
my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/tests_dumps/mouse/err_1e7.err', 'r');
while (<$fh>) {
  chomp;
  my ($slice_start, $slice_end, $start, $end) = split/\s/;
  if ($slice_start <= 131603818  && 131603818  <= $slice_end) {
    print STDERR $_, "\n";
  }
}
$fh->close;
}

if (1) {
my $vfa = $registry->get_adaptor('mouse', 'variation', 'variationfeature');
my $sa = $registry->get_adaptor('mouse', 'core', 'slice');
#my $slice = $sa->fetch_by_region('chromosome', '2', 19169815, 28754722);
my $slice = $sa->fetch_by_region('chromosome', '2', 124603792, 134188699);

my $vf_it = $vfa->fetch_Iterator_by_Slice($slice);  

while (my $vf = $vf_it->next) {
  my $vf_start = $vf->seq_region_start;
  my $vf_end = $vf->seq_region_end;
#  print STDERR "$vf_start $vf_end ", $vf->dbID, ' ', $vf->variation_name, "\n";
}

my @vfs = @{$vfa->fetch_all_by_Slice($slice)};
foreach my $vf (@vfs) {
  my $vf_start = $vf->seq_region_start;
  my $vf_end = $vf->seq_region_end;
#  print STDERR ">$vf_start $vf_end ", $vf->dbID, ' ', $vf->variation_name, "\n";
}
}
