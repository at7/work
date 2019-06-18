use strict;
use warnings;

use Bio::EnsEMBL::IO::Parser::BigWig;
use Bio::EnsEMBL::Registry;
use Data::Dumper;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 96,
);

my $va = $registry->get_adaptor('human', 'variation', 'variation');
my $vfa = $registry->get_adaptor('human', 'variation', 'variationfeature');
# COSM6596488
my $variation = $va->fetch_by_name('rs699');

my $vf = $variation->get_all_VariationFeatures->[0];
my $gerp_score = $vf->get_gerp_score;
print Dumper($gerp_score), "\n";

my $cadd_scores = $vf->get_all_cadd_scores;
print Dumper($cadd_scores), "\n";
foreach my $allele (keys %$cadd_scores) {
  print $allele, ' ', $cadd_scores->{$allele}, "\n";
}

=bgin
my $file = '/hps/nobackup2/production/ensembl/anja/GERP/gerp_conservation_scores.homo_sapiens.bw';
my $ftp_file = 'ftp://ftp.ensembl.org/pub/current_compara/conservation_scores/70_mammals.gerp_conservation_score/gerp_conservation_scores.homo_sapiens.bw';
my $test_file = '/homes/anja/bin/ensembl-io/modules/t/input/out.bw';
my $test_file2 = '/homes/anja/bin/ensembl-variation/modules/t/testdata/gerp.bw';
my $test_file3 = '/homes/anja/bin/ensembl-io/modules/t/input/data-fixedStep.bw';

my $parser = Bio::EnsEMBL::IO::Parser::BigWig->open($file);

my $return =  $parser->seek(2, 45417422, 45417424);

while ($parser->next) {
  print join(" ", $parser->get_seqname, $parser->get_start, $parser->get_end, $parser->get_score), "\n";
}
=end
=cut

