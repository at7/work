use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Slice qw(split_Slices);

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'mysql-ens-mirror-1',
  -user => 'ensro',
  -port => 4240,
  -DB_version => 96,
);


my $species = 'human';

my $slice_adaptor = $registry->get_adaptor($species, 'core', 'slice');
my $vfa = $registry->get_adaptor($species, 'variation', 'variationfeature');
my $va = $registry->get_adaptor($species, 'variation', 'variation');
my $tva = $registry->get_adaptor($species, 'variation', 'transcriptvariation');

my $transcript_adaptor = $registry->get_adaptor($species, 'core', 'transcript');
my $gene_adaptor = $registry->get_adaptor($species, 'core', 'gene');

my $lrg = $transcript_adaptor->fetch_by_stable_id('LRG_202t1');
my $lrg_gene = $gene_adaptor->fetch_by_stable_id('LRG_202');
my $variation = $va->fetch_by_name('rs6711382');
my $vf = $variation->get_all_VariationFeatures->[0];


foreach my $tv (@{$tva->fetch_all_by_VariationFeatures([$vf])}) {
    my $tv_stable_id = $tv->transcript_stable_id;
    print $tv_stable_id, "\n";
    my $vf = $tv->variation_feature;
    my $vf_id = $vf->dbID;
    print "variation_feature_id $vf_id\n";
    my @alleles = split /\//, $vf->allele_string;
    print $vf->allele_string, "\n";
    my $ref_seq = shift @alleles unless @alleles == 1; # shift off the reference allele
    foreach my $tv_allele (@{$tv->get_all_alternate_TranscriptVariationAlleles}) {
        my $vf_seq = $tv_allele->variation_feature_seq;
        print $vf_seq, "\n";
        print  $tv_allele->codon_allele_string, "\n";
        print "Allele string ", $tv_allele->allele_string,"\n";
        #for my $oc (@{$tv_allele->get_all_OverlapConsequences}) {
        #}
    }
}

