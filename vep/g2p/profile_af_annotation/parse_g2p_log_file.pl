use strict;
use warnings;

use FileHandle;
use Data::Dumper;


my $fh = FileHandle->new('/homes/anja/bin/work/vep/g2p/profile_af_annotation/g2p_log_dir_2019_5_15_16_14/55222.txt', 'r');

my $individual_data = {};
my $frequency_data = {};
my $vf_annotation_data = {}; # tva annotations, transcript dependent
my $tva_annotation_data = {}; # tva annotations, transcript dependent
my $canonical_transcripts = {};
my $all_g2p_genes = {};
my $vcf_g2p_genes = {};
my $highest_frequencies = {};
my $ar_data = {};

my $g2p_transcripts = {};

my $rules = {
  'biallelic' => { af => 0.005, rules => {HET => 2, HOM => 1} },
  'monoallelic' => { af => 0.0001, rules => {HET => 1, HOM => 1} },
  'hemizygous' => { af => 0.0001, rules => {HET => 1, HOM => 1} },
  'x-linked dominant' => { af => 0.0001, rules => {HET => 1, HOM => 1} },
  'x-linked over-dominance' => { af => 0.0001, rules => {HET => 1, HOM => 1} },
};

my $g2p_genes = {};

while (<$fh>) {
  chomp;
  next if /^log/;
  #G2P_individual_annotations  ENSG00000091140 DLD ENST00000450038 7_107545113_T/C HOM P10
  if (/^G2P_individual_annotations/) {
    my ($flag, $gene_stable_id, $gene_symbol, $transcript_stable_id, $vf_cache_name, $zyg, $individual) = split/\t/;
    $individual_data->{$individual}->{$gene_stable_id}->{$transcript_stable_id}->{$zyg}->{$vf_cache_name} = 1; 
  }

  elsif (/^G2P_frequencies/) {
    my ($flag, $vf_cache_name, $frequencies) = split/\t/;
    $frequency_data->{$vf_cache_name}->{$frequencies} = 1;
    my $highest_frequency = get_highest_frequency($frequencies);
    $highest_frequencies->{$vf_cache_name} = $highest_frequency;
  }

  elsif (/^G2P_vf_annotations/) {
    my ($flag, $vf_cache_name, $annotations) = split/\t/;
    $tva_annotation_data->{$vf_cache_name}->{$annotations} = 1;
  }

  elsif (/^G2P_existing_vf_annotations/) {
    my ($flag, $vf_cache_name, $annotations) = split/\t/;
    $vf_annotation_data->{$vf_cache_name}->{$annotations} = 1;
  }

  elsif (/^G2P_gene_data/) {
    my ($flag, $gene_id, $ars) = split/\t/;
    foreach my $ar (split(',', $ars)) {
      $ar_data->{$gene_id}->{$ar} = 1;
    }
  }

  elsif (/^G2P_in_vcf/) {
    my ($flag, $gene_id) = split/\t/;
    $vcf_g2p_genes->{$gene_id} = 1;
  }

  elsif (/^G2P_transcript_data/) {
    my ($flag, $gene_id, $transcript_id, $is_canonical) = split/\t/;
    $canonical_transcripts->{$gene_id}->{$transcript_id} = 1;
  }
  else {
    print $_, "\n";
  }
}

foreach my $individual_id (keys %$individual_data) {
  foreach my $gene_id (keys %{$individual_data->{$individual_id}}) {
    foreach my $transcript_id (keys %{$individual_data->{$individual_id}->{$gene_id}}) {
      foreach my $ar (keys %{$ar_data->{$gene_id}}) {
        my $zyg2var = $individual_data->{$individual_id}->{$gene_id}->{$transcript_id};
        my $fulfils_ar = obeys_rule($ar, $zyg2var);
        if (scalar keys %$fulfils_ar > 0) {
          $g2p_transcripts->{$transcript_id}->{$ar} = $fulfils_ar;
        }
      }
    }
  }
}

print Dumper $individual_data;
print Dumper $frequency_data;
print Dumper $vf_annotation_data;
print Dumper $highest_frequencies;
print Dumper $g2p_transcripts;

$fh->close;

#AFR:A:0,AMR:A:0,EAS:A:0.001,EUR:A:0,SAS:A:0,gnomAD:A:1.194e-05,gnomAD_AFR:A:0,gnomAD_AMR:A:0,gnomAD_ASJ:A:0,gnomAD_EAS:A:0,gnomAD_FIN:A:4.621e-05,gnomAD_NFE:A:1.76e-05,gnomAD_OTH:A:0,gnomAD_SAS:A:0
sub get_highest_frequency {
  my $frequencies = shift;
  my $highest_frequency = 0; 
  foreach my $frequency_annotation (split(',', $frequencies)) {
    my $frequency = (split(':', $frequency_annotation))[-1];
    if ($frequency >  $highest_frequency) {
      $highest_frequency = $frequency;
    }
  }
  return $highest_frequency;
}

sub obeys_rule {
  my $ar = shift;
  my $zyg2variants = shift;
  my $ar_rules = $rules->{$ar};
  my $af_threshold = $ar_rules->{af};
  my $zyg2counts = $ar_rules->{rules};
  my $results = {};
  foreach my $zyg (keys %$zyg2counts) {
    my $count = $zyg2counts->{$zyg};
    my $variants = exceeds_threshold($af_threshold, $zyg2variants->{$zyg}); 
    if (scalar @$variants >= $count) {
      $results->{$zyg} = $variants;
    }
  }
  return $results;
}

sub exceeds_threshold {
  my $af_threshold = shift;
  my $variants = shift;
  my @pass_variants = ();
  foreach my $variant (keys %$variants) {
    if (!defined $highest_frequencies->{$variant} || $highest_frequencies->{$variant} <= $af_threshold) {
      push @pass_variants, $variant;
    }
  }
  return \@pass_variants;
}


