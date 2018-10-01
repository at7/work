use strict;
use warnings;

use Bio::DB::Fasta;


my $fasta_db = Bio::DB::Fasta->new('/hps/nobackup2/production/ensembl/anja/release_94/dog/remapping/old_assembly/');

my @ids = $fasta_db->get_all_primary_ids;
my $sequence_name_2_id = {};
foreach my $id (@ids) {
  print STDERR $id, "\n";
#  my @components = split/:/, $id;
#  my $sequence_name = $components[2];
#  $sequence_name_2_id->{$sequence_name} = $id;
}


#my $sequence_id = $sequence_name_2_id->{'1'};
#print $fasta_db->seq("$sequence_id:15728791,15728791"), "\n";
#print $fasta_db->seq("$sequence_id:20510738,20510738"), "\n";


