use strict;
use warnings;
use Scalar::Util qw(looks_like_number);


use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Slice qw(split_Slices);
use Bio::EnsEMBL::VEP::Runner;

my $registry = 'Bio::EnsEMBL::Registry';
Bio::EnsEMBL::Registry->clear();
=begin
my $file = '/gpfs/nobackup/ensembl/anja/ensembl.registry';

$registry->load_all($file);

my $species = 'human';

my $sa = $registry->get_adaptor($species, 'core', 'slice');

my $ta = $registry->get_adaptor($species, 'core', 'transcript');
my $tva = $registry->get_adaptor($species, 'variation', 'transcriptvariation');
my $vfa = $registry->get_adaptor($species, 'variation', 'variationfeature');


my $va =  $registry->get_adaptor($species, 'variation', 'variation');
my $v = $va->fetch_by_name('rs769004202');
my $vf = $v->get_all_VariationFeatures->[0];

my  ($transcript) =
    @{ $ta->fetch_all_by_external_name('ENST00000474393') };

#$print $transcript, "\n";
#print $transcript->spliced_seq, "\n";
=end
=cut
#1 1522770 1522770
#
#my $slice = $sa->fetch_by_region('toplevel', 'AL645728.31');
#print $slice->seq, "\n";
#my $vfold = Bio::EnsEMBL::Variation::VariationFeature->new(
#  -start => 1522770,
#  -end => 1522770,
#  -slice => $transcript->{slice},           # the variation must be attached to a slice
#  -allele_string => 'T/C',    # the first allele should be the reference allele
#  -strand => 1,
#  -map_weight => 1,
#  -adaptor => $vfa,           # we must attach a variation feature adaptor
#  -variation_name => 'rs1135025_test',
#);
#my $tv = Bio::EnsEMBL::Variation::TranscriptVariation->new(
#          -transcript        => $transcript,
#          -variation_feature => $vfold,
#          -adaptor           => $tva,
#          -no_ref_check      => 1,
#          -no_transfer       => 1,
#          -use_feature_ref   => 0,
#        );

#my $alleles = $tv->get_all_alternate_VariationFeatureOverlapAlleles; 

#my $toplevel_slices = $sa->fetch_all('toplevel', undef, 1);
#foreach my $slice (@$toplevel_slices) {
#  print $slice->seq_region_name, ' ', $slice->get_seq_region_id, "\n";
#}
open IN, '/gpfs/nobackup/ensembl/anja/vep_dumps/dump_vep_human_92/dumps/qc/homo_sapiens_GRCh38_human_frequency_test_input.txt';
my $ref_data_hash = {};
while(<IN>) {
  chomp;
  my @tmp = split(/\s+/, $_);
  $ref_data_hash->{$tmp[5]} = [map {s/^.+?\://g; $_} @tmp];
}
close IN;
my $runner = Bio::EnsEMBL::VEP::Runner->new({
    species => 'homo_sapiens',
    assembly => 'GRCh38',
    db_version => 92,
    cache_version => 92,
    offline => 0,
    cache => 1,
    database => 0,
#    dbname => 'homo_sapiens_otherfeatures_92_38',
    host => 'mysql-ens-general-prod-1',
    user => 'ensro',
    port => 4525,
    no_cache => 1,
    password => '',
    is_multispecies => 1,
    dir => '/gpfs/nobackup/ensembl/anja/vep_dumps/dump_vep_human_92/dumps/qc/21e0d718c36a4bdfb5fb779848cebdb3',
    input_file => '/gpfs/nobackup/ensembl/anja/vep_dumps/dump_vep_human_92/dumps/qc/homo_sapiens_GRCh38_human_frequency_test_input.txt',
    format => 'ensembl',
    delimiter => " ",
    output_format => 'tab',
    safe => 1,
    quiet => 1,
    no_stats => 1,
    check_existing => 0,
    af_1kg => 1,
    af_esp => 1,
    af_gnomad => 1,
    fields => 'Uploaded_variation,AFR_AF,AMR_AF,EAS_AF,EUR_AF,SAS_AF,AA_AF,EA_AF,gnomAD_AF,gnomAD_AFR_AF,gnomAD_AMR_AF,gnomAD_ASJ_AF,gnomAD_EAS_AF,gnomAD_FIN_AF,gnomAD_NFE_AF,gnomAD_OTH_AF,gnomAD_SAS_AF',
    buffer_size => 1,
    pick => 1,
    failed => 1,
    # check_ref => 1,
    warning_file => '/gpfs/nobackup/ensembl/anja/warnings.txt',
    refseq => 1,
  });

#foreach my $key (keys %{$runner->{'_config'}->{'_params'}}) {
#  print STDERR $key, ' ', $runner->{'_config'}->{'_params'}->{$key}, "\n";
#}
#foreach my $key (keys %{$runner->{'_config'}->{'_raw_config'}}) {
#  print STDERR $key, ' ', $runner->{'_config'}->{'_raw_config'}->{$key}, "\n";
#}

#die;




while(my $line = $runner->next_output_line()) {
  print STDERR $line, "\n";
  my @data = split("\t", $line);
  my $rs = shift @data;

    if(my $ref_data = $ref_data_hash->{$rs}) {

      # ref_data contains all the input bits too, shift them off
      while(@$ref_data > @data) {
        shift @$ref_data;
      }

      # now compare
      my $mismatches = 0;

      for my $i(0..$#data) {
        next unless looks_like_number($ref_data->[$i]);
        $mismatches++ if !looks_like_number($data[$i]) || sprintf("%.3g", $ref_data->[$i]) != sprintf("%.3g", $data[$i]);
      }

      if($mismatches) {
        print STDERR "ERROR: Mismatched frequencies in $rs (IN vs OUT):\n".join("\t", @$ref_data)."\n".join("\t", @data)."\n";
      }
    }
    else {
      print STDERR "ERROR: no ref data found for $rs\n";
    }

}


