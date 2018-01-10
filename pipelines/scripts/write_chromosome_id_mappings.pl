use strict;
use warnings;

use FileHandle;

my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_91/pig/remapping_test/old_assembly/chromosome_id_mappings_before', 'r');

my $fh_out = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_91/pig/remapping_test/old_assembly/chromosome_id_mappings', 'w');


while (<$fh>) {
  chomp;
#>scaffold:Sscrofa11.1:Y_unloc_scaf7:1:81402:1 scaffold Y_unloc_scaf7
  my ($fasta_id, $coord_type, $seq_region_name) = split/\s+/;
  $fasta_id =~ s/\>//;

  print $fh_out "$fasta_id\t$seq_region_name\n";

}
$fh->close();
$fh_out->close();
