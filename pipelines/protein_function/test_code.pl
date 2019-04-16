use strict;
use warnings;

use Data::Dumper;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Variation::Utils::DbNSFPProteinFunctionAnnotation;

my $registry_file = '/hps/nobackup2/production/ensembl/anja/release_97/human/development/ensembl.registry.96';

my $dbNSFP = Bio::EnsEMBL::Variation::Utils::DbNSFPProteinFunctionAnnotation->new(
  -registry_file => $registry_file,
  -species => 'Homo_sapiens',
  -dbnsfp_file => 'dbNSFP3.5a_grch37.txt.gz',
  -assembly => 'GRCh37',
  -annotation_file_version => '3.5a',
  -pipeline_mode => 0,
  -debug_mode => 1,
);


my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all($registry_file);

my $translation_adaptor = $registry->get_adaptor('human', 'core', 'translation');
#my $translations = $translation_adaptor->fetch_all;
#foreach my $translation (@$translations) {
#  my $transcript = $translation->transcript;
#  my $strand = $transcript->seq_region_strand;
#  print $translation->stable_id, ' ', $strand, "\n";
#}

#my $all_triplets = $dbNSFP->get_triplets('ENSP00000435699');
#my $first_triplet = $all_triplets->[0];
#my $last_triplet = $all_triplets->[scalar @$all_triplets - 1];
#print Dumper($first_triplet), "\n"; # start 32890598
#print Dumper($last_triplet), "\n"; # end 32907427

my $all_triplets = $dbNSFP->get_triplets('ENSP00000299335');
my $first_triplet = $all_triplets->[0];
my $last_triplet = $all_triplets->[scalar @$all_triplets - 1];
print Dumper($first_triplet), "\n"; # start 155989956
#print Dumper($last_triplet), "\n"; # end 155989029

#my $all_triplets =$dbNSFP->get_triplets('ENSP00000432831');
#print Dumper($all_triplets), "\n";

#ENSP00000432831 -1
#ENSP00000435699 1

