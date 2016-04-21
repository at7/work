use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::MappedSliceContainer;
use Bio::EnsEMBL::Variation::DBSQL::StrainSliceAdaptor;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
-host => 'ensembldb.ensembl.org',
-user => 'anonymous'
);

my $print_sgfs = 0;
my $print_afs = 0;

my $data = {
  human => {
    samples => [
      '1000GENOMES:phase_3:HG00341',
    ],
    regions => [
#      { chr => 1, start => 3_225_000, end => 3_225_500 },
      { chr => 1, start => 3_214_482, end => 3_315_000 },
      { chr => 1, start => 3_214_482, end => 3_671_498 },
    ],
    species => 'homo_sapiens',
  },
  mouse => {
    samples => [
      'MGP:A/J',
      'MGP:SPRET/EiJ',
    ],
    regions => [
      { chr => 1, start => 3_214_482, end => 3_215_000 },
      { chr => 1, start => 3_214_482, end => 3_671_498 },
    ],
    species => 'mus_musculus',
  },
};

my $short_name = 'human'; # human, mouse
my $species = $data->{$short_name}->{species};
my $regions = $data->{$short_name}->{regions};
my $samples = $data->{$short_name}->{samples};

my $slice_adaptor = $registry->get_adaptor($species, 'core', 'slice');
my $vdb = $registry->get_DBAdaptor($species, 'variation');
my $strain_slice_adaptor = $registry->get_adaptor($species, 'variation', 'StrainSlice');
$strain_slice_adaptor->db->use_vcf(1);
my $sgfa = $registry->get_adaptor($species, 'variation', 'SampleGenotypeFeature'); # -> fetch_all_by_Slice
my $sga = $registry->get_adaptor($species, 'variation', 'SampleGenotype'); # -> fetch_all_by_Variation
my $sample_adaptor = $registry->get_adaptor($species, 'variation', 'Sample');
my $afa = $registry->get_adaptor($species, 'variation', 'AlleleFeature');

my $region = $regions->[0];

my $slice = $slice_adaptor->fetch_by_region('chromosome', $region->{chr}, $region->{start}, $region->{end});
print $slice->length, "\n";

if ($print_sgfs) {
  foreach my $name (@$samples) {
    my $sample = $sample_adaptor->fetch_all_by_name($name)->[0];
    print $sample->name, "\n";
    my $sgfs = $sgfa->fetch_all_by_Slice($slice, $sample);
    foreach my $sgf (@$sgfs) {
    # genotype, genotype_string, variation, subsnp, subsnp_handle, ambiguity_code, phased, allele, sample, variation_feature    
      my $v = $sgf->variation;
      my $var_class = $v->var_class;
      my $var_name = $v->name;
      my $vf = $sgf->variation_feature;
      my $allele_string = $vf->allele_string;
      my $genotype_array = $sgf->genotype;
      my $genotype = join(',', @$genotype_array);
      my $genotype_string = $sgf->genotype_string;
      if ($var_class ne 'SNP') {
        print "$var_name $var_class $allele_string $genotype $genotype_string\n";    
      }
    }
    print scalar @$sgfs, "\n";
  }
}

if ($print_afs) {
  foreach my $name (@$samples) {
    my $sample = $sample_adaptor->fetch_all_by_name($name)->[0];
    my $afs = $afa->fetch_all_by_Slice($slice, $sample);
    print scalar @$afs, "\n"; 
    foreach my $af (@$afs) {
  #    next if ($af->_is_sara);
      my $var_name = $af->variation->name;
      my $var_class = $af->variation->var_class;
      my $alt_allele = $af->alt_allele;
      my $vf_allele_string = $af->vf_allele_string;
      my $genotype_string = $af->genotype_string;
      my $length = $af->length;
      my $length_diff = $af->length_diff;
      if ($length_diff != 0) {
        print "$var_name $var_class alt_allele: $alt_allele VF_alleles: $vf_allele_string GT $genotype_string length $length length_diff $length_diff\n";
      }
    }
  }
}


my $msc = Bio::EnsEMBL::MappedSliceContainer->new(-SLICE => $slice, -EXPANDED => 1);

$msc->set_StrainSliceAdaptor(Bio::EnsEMBL::Variation::DBSQL::StrainSliceAdaptor->new($vdb));

foreach my $name (@$samples) {
  print $name, "\n";
  $msc->attach_StrainSlice($name);
}

foreach (@{$msc->get_all_MappedSlices}) {
  my $slice = $_->get_all_Slice_Mapper_pairs->[0][0];
#  print $_->seq(1), "\n";
#    slice => $slice,
#    seq   => $_->seq(1)
}

=begin
foreach my $mapped_slice (@{$msc->get_all_MappedSlices}) {
#  print $mapped_slice->seq(1), "\n";
  foreach my $pair (@{ $mapped_slice->get_all_Slice_Mapper_pairs }) {
    my ($slice, $mapper) = @$pair;
    foreach my $key (keys %$mapper) {
      print $key, "\n";
    }
print 'to ', $mapper->{to}, "\n";
print 'from ', $mapper->{from}, "\n";

    my @coords = $mapper->map_coordinates(
                    $slice->seq_region_name,
                    $slice->start,
                    $slice->end,
                    $slice->strand,
                    'mapped_slice'
                  );
    print scalar @coords, "\n";
    foreach my $coord (@coords) {
      print $coord->length, "\n";
    }

  }
#  my $slice = $_->get_all_Slice_Mapper_pairs->[0][0];
#  print $_->seq(1), "\n";
#  print length $slice, "\n";
#  push @slices, {
#    name  => $slice->can('display_Slice_name') ? $slice->display_Slice_name : $config->{'species'},
#    slice => $slice,
#    seq   => $_->seq(1)
#  };
}

my $mapper = $msc->mapper;
foreach my $key (keys %$mapper) {
  print $key, "\n";
}

print 'to ', $mapper->{to}, "\n";
print 'from ', $mapper->{from}, "\n";
=end
=cut

#my $sample_slice = $strain_slice_adaptor->get_by_strain_Slice($strain_name, $slice);
#my $sample_slice2 = $strain_slice_adaptor->get_by_strain_Slice($strain_name2, $slice);
#my $afs = $sample_slice->get_all_AlleleFeatures();
#my $differences = $sample_slice->get_all_differences_StrainSlice($sample_slice2);
#print scalar @$afs, "\n";
#print scalar @$differences, "\n";
