use strict;
use warnings;

use Bio::EnsEMBL::IO::Parser::BigWig;
use Bio::EnsEMBL::Registry;
my $registry = 'Bio::EnsEMBL::Registry';

my $file = '/hps/nobackup2/production/ensembl/anja/GERP/gerp_conservation_scores.homo_sapiens.bw';

my $parser = Bio::EnsEMBL::IO::Parser::BigWig->open($file);

my $return =  $parser->seek(10, 102918295, 102918300);

while ($parser->next) {
  print join(" ", $parser->get_seqname, $parser->get_start, $parser->get_end, $parser->get_score), "\n";
}


