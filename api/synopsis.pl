use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(-host => 'ensembldb.ensembl.org', -user => 'anonymous');

allele_adaptor();
individual_adaptor();
population_genotype_adaptor();
transcript_variation_adaptor();
variation_feature_adaptor();

sub allele_adaptor {
  my $aa = $registry->get_adaptor('human', 'variation', 'allele');
  my $va = $registry->get_adaptor('human', 'variation', 'variation');

  my $variation = $va->fetch_by_name('rs678');
  my $alleles = $aa->fetch_all_by_Variation($variation);
  foreach my $allele (@$alleles) {
    my $allele_string = $allele->allele();
    my $population_name = ($allele->population()) ? $allele->population()->name : 'population is NA';
    my $frequency = ($allele->frequency()) ? $allele->frequency : 'frequency is NA';
    print join(' ', $allele_string, $population_name, $frequency), "\n";
  }
}

sub individual_adaptor {
  my $ia = $registry->get_adaptor('human', 'variation', 'individual');
  my $pa = $registry->get_adaptor('human', 'variation', 'population');

  # Get all Individuals with a particular name
  foreach my $individual (@{ $ia->fetch_all_by_name('CEPH1362.01') }) {
    print $individual->name(), "\n";
  }

  # get all Individuals from a Population
  my $population = $pa->fetch_by_name('THOWARDEMORY:Coriell');
  foreach my $individual (@{ $ia->fetch_all_by_Population($population) }) {
    print $individual->name(), "\n";
  }

  # get all children of an Individual
  my $individuals = $ia->fetch_all_by_name('CEPH1362.01');
  my $individual  = $individuals->[0];
  foreach my $child (@{ $ia->fetch_all_by_parent_Individual($individual) }) {
    print $child->name(), " is a child of ", $individual->name(), "\n";
  }
}

sub population_genotype_adaptor {
  my $pga = $registry->get_adaptor('human', 'variation', 'populationgenotype');
  my $va = $registry->get_adaptor('human', 'variation', 'variation');

  # Get a PopulationGenotype by its internal identifier
  my $pgtype = $pga->fetch_by_dbID(145);
  print join(' ', $pgtype->population()->name(), $pgtype->allele1(), $pgtype->allele2(), $pgtype->frequency()), "\n";

  # Get all population genotypes for a variation
  my $variation = $va->fetch_by_name('rs1121');
  foreach $pgtype (@{ $pga->fetch_all_by_Variation($variation) }) {
    print join(' ', $pgtype->population()->name(), $pgtype->allele1(), $pgtype->allele2(), $pgtype->frequency()), "\n";
  }

  my $sa = $registry->get_adaptor('human', 'core', 'slice');
  my $igta = $registry->get_adaptor('human', 'variation', 'individualgenotype');

  # Fetch region for which we want to get all individual genotypes
  my $slice = $sa->fetch_by_region('chromosome', '3', 52_786_960, 52_786_970);
  my $individual_genotypes = $igta->fetch_all_by_Slice($slice);

  foreach my $igt (@$individual_genotypes) {
    my $variation_name = $igt->variation()->name;
    my $genotype = $igt->genotype_string;
    my $individual_name = $igt->individual()->name;
    print "$variation_name\t$genotype\t$individual_name\n";
  }
}

sub transcript_variation_adaptor {
  my $ta  = $registry->get_adaptor('human', 'core', 'Transcript');
  my $tva = $registry->get_adaptor('human', 'variation', 'TranscriptVariation');
  my $va  = $registry->get_adaptor('human', 'variation', 'Variation');
  my $vfa = $registry->get_adaptor('human', 'variation', 'VariationFeature');

  # fetch all TranscriptVariations related to a Transcript
  my $transcript = $ta->fetch_by_stable_id('ENST00000380152');
  for my $tv (@{ $tva->fetch_all_by_Transcripts([$transcript]) }) {
    print $tv->display_consequence, "\n";
  }
  
  # fetch all TranscriptVariations related to a VariationFeature
  my $vf = $vfa->fetch_all_by_Variation($va->fetch_by_name('rs669'))->[0];
  for my $tv (@{ $tva->fetch_all_by_VariationFeatures([$vf]) }) {
    print $tv->display_consequence, "\n";
  }
  # fetch all TranscriptVariations related to a Translation
  for my $tv (@{ $tva->fetch_all_by_translation_id('ENSP00000447797') }) {
    foreach my $allele (keys %{$tv->hgvs_protein}) {
      my $hgvs_notation = $tv->hgvs_protein->{$allele} || 'hgvs notation is NA';
      print "$allele $hgvs_notation\n";
    }    
  }
  # fetch all TranscriptVariations related to a Translation with given SO terms
  for my $tv (@{ $tva->fetch_all_by_translation_id_SO_terms('ENSP00000447797', ['missense_variant']) }) {
    foreach my $allele (keys %{$tv->hgvs_protein}) {
      my $hgvs_notation = $tv->hgvs_protein->{$allele} || 'hgvs notation is NA';
      print "$allele $hgvs_notation\n";
    }    
  }
}

sub variation_feature_adaptor { 
  my $vfa = $registry->get_adaptor('human', 'variation', 'variationfeature');
  my $sa = $registry->get_adaptor('human', 'core', 'slice');
  my $va = $registry->get_adaptor('human', 'variation', 'variation');

  # Get a VariationFeature by its internal identifier
  my $vf = $va->fetch_by_dbID(145);

  # Include the variations that have been flagged as failed
  $vfa->db->include_failed_variations(1);

  # Get all VariationFeatures in a region
  my $slice = $sa->fetch_by_region('chromosome', 'X', 1e6, 2e6);
  foreach my $vf ( @{ $vfa->fetch_all_by_Slice($slice) } ) {
    print $vf->start(), '-', $vf->end(), ' ', $vf->allele_string(), "\n";
  }

  # Fetch all genome hits for a particular variation
  my $v = $va->fetch_by_name('rs56');

  foreach my $vf ( @{ $vfa->fetch_all_by_Variation($v) } ) {
    print $vf->seq_region_name(), $vf->seq_region_start(), '-',
          $vf->seq_region_end(), "\n";
  }

}

