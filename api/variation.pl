use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;


my $fh = FileHandle->new('VEPWebDbNSFP.txt', 'r');
my $headers;
my $vep_results = {};
while (<$fh>) {
  chomp;
  if (/#/) {
    $headers = [split];
  } else {
    my @split = split /\t/;
    my %data = map {$headers->[$_] => $split[$_]} (0..(scalar @{$headers} - 1));
    my $variant = $data{'#Uploaded_variation'}; 
    my $consequence = $data{Consequence};
    my $transcript = $data{Feature};
    my $allele = $data{Allele}; 
    my $revel = $data{REVEL_score};
    my $cadd = $data{CADD_raw};
    my $meta_lr = $data{MetaLR_score};
#MetaLR_score 
    my $mutation_assessor = $data{MutationAssessor_score_rankscore};
#MutationAssessor_score_rankscore
    print STDERR "$variant $transcript $allele $revel $meta_lr $mutation_assessor\n";
    if ($consequence eq 'missense_variant') {
      $vep_results->{$variant}->{$transcript}->{$allele}->{revel} = $revel;
      $vep_results->{$variant}->{$transcript}->{$allele}->{cadd} = $cadd;
      $vep_results->{$variant}->{$transcript}->{$allele}->{meta_lr} = $meta_lr;
      $vep_results->{$variant}->{$transcript}->{$allele}->{mutation_assessor} = $mutation_assessor;
    } 
  }
}
$fh->close;


my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_94/human/ensembl.registry');
my $vdba = $registry->get_DBAdaptor('human', 'variation');
my $cdba = $registry->get_DBAdaptor('human', 'core');


my $variation_adaptor = $vdba->get_VariationAdaptor;
my $transcript_adaptor = $cdba->get_TranscriptAdaptor;
foreach my $id (qw/rs553503473 rs1490101435 rs771962715 rs6077510 rs774471904 rs763852213 rs1474255319 rs773891227 rs750693957 rs1410644433/) {
  my $variation = $variation_adaptor->fetch_by_name($id);
  my $vfs = $variation->get_all_VariationFeatures;
  my $vf = $vfs->[0];

  my $tvs = $vf->get_all_TranscriptVariations();
  foreach my $tv (@$tvs) {
    my $tvas = $tv->get_all_alternate_TranscriptVariationAlleles;
    my $consequence = join(',', @{$tv->consequence_type});
    next unless ($consequence =~ /missense/);
    my $transcript_id = $tv->transcript->stable_id;
    foreach my $tva (@$tvas) {
      my $cadd_score = $tva->cadd_score || 'DB NA';
      my $dbnsfp_revel_score = $tva->dbnsfp_revel_score || 'DB NA';
      my $dbnsfp_meta_lr_score = $tva->dbnsfp_meta_lr_score || 'DB NA';
      my $dbnsfp_mutation_assessor_score = $tva->dbnsfp_mutation_assessor_score || 'DB NA';
      my $allele = $tva->variation_feature_seq;
      my $vep_revel = $vep_results->{$id}->{$transcript_id}->{$allele}->{revel} || 'NA';
      my $vep_cadd = $vep_results->{$id}->{$transcript_id}->{$allele}->{cadd} || 'NA';
      my $vep_meta_lr = $vep_results->{$id}->{$transcript_id}->{$allele}->{meta_lr} || 'NA';
      my $vep_mutation_assessor = $vep_results->{$id}->{$transcript_id}->{$allele}->{mutation_assessor} || 'NA';

      print STDERR "$id $allele $transcript_id cadd $cadd_score $vep_cadd revel $dbnsfp_revel_score $vep_revel meta_lr $dbnsfp_meta_lr_score $vep_meta_lr mutation_assessor $dbnsfp_mutation_assessor_score $vep_mutation_assessor\n";
    }
  }
}

=begin
rs553503473
rs1490101435
rs771962715
rs6077510
rs774471904
rs763852213
rs1474255319
rs773891227
rs750693957
rs1410644433

G dbnsfp_revel_score 0.385 dbnsfp_meta_lr_score 0.241 dbnsfp_mutation_assessor_score 0.894
G dbnsfp_revel_score 0.385 dbnsfp_meta_lr_score 0.241 dbnsfp_mutation_assessor_score 0.894
rs773891227     New        29        0.385      0.241        0.894
rs773891227     VEP         23.2     0.312      0.1684      0.45580 

17:40416800-40416802 40416801 1 T A L Q
revel 39 Q likely benign 0.199
meta_lr 39 Q tolerated 0.1083
mutation_assessor 39 Q medium 0.64738

17:40416800-40416802 40416801 1 T C R Q
revel 39 P likely benign 0.385
meta_lr 39 P tolerated 0.2417
mutation_assessor 39 P medium 0.89405

17:40416800-40416802 40416801 1 T G P Q
revel 39 R likely benign 0.312
meta_lr 39 R tolerated 0.1684
mutation_assessor 39 R low 0.45580
=end
=cut




