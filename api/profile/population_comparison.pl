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
my $print_strain_slice = 0;
my $test_strain_slice = 1;

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
#      'MGP:A/J',
      'MGP:SPRET/EiJ',
#      'MGP:WSB/EiJ',
    ],
    regions => [
      { chr => 1, start => 3_574_805, end => 3_574_845 }, #1:3570888-3571887
      { chr => 1, start => 3_570_888, end => 3_577_950 }, #1:3570888-3571887
      { chr => 1, start => 3_570_888, end => 3_570_950 }, #1:3570888-3571887
      { chr => 1, start => 3_214_482, end => 3_671_498 },
      { chr => 1, start => 3_214_482, end => 3_215_000 },
    ],
    species => 'mus_musculus',
  },
};

my $short_name = 'mouse'; # human, mouse
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

my $pa = $registry->get_adaptor($species, 'variation', 'Population');

#my $populations = $pa->fetch_all_1KG_Populations();
#foreach my $population (@$populations) {
#  print $population->name, "\n";
#}

my $region = $regions->[0];

my $slice = $slice_adaptor->fetch_by_region('chromosome', $region->{chr}, $region->{start}, $region->{end});

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

if ($print_strain_slice) {
  my $msc = Bio::EnsEMBL::MappedSliceContainer->new(-SLICE => $slice, -EXPANDED => 1);
  $msc->set_StrainSliceAdaptor(Bio::EnsEMBL::Variation::DBSQL::StrainSliceAdaptor->new($vdb));
  foreach my $name (@$samples) {
    print "Attach $name\n";
    $msc->attach_StrainSlice($name);
    print "\n";
  }
#  my @slices = ({
#    name  => $config->{'ref_slice_name'},
#    slice => $ref_slice_obj
#  });

  foreach (@{$msc->get_all_MappedSlices}) {
    my $slice = $_->get_all_Slice_Mapper_pairs->[0][0];
    print $slice->sample->name, "\n";
    print $_->seq(1), "\n";
    print "\n";
#    push @slices, {
#      name  => $slice->can('display_Slice_name') ? $slice->display_Slice_name : $config->{'species'},
#      slice => $slice,
#      seq   => $_->seq(1)
#    };
  }
}


if ($test_strain_slice) {
  my $msc = Bio::EnsEMBL::MappedSliceContainer->new(-SLICE => $slice, -EXPANDED => 1);
  $msc->set_StrainSliceAdaptor(Bio::EnsEMBL::Variation::DBSQL::StrainSliceAdaptor->new($vdb));
  my $name = $samples->[0]; 
  my $strain_slice = $strain_slice_adaptor->get_by_strain_Slice($name, $slice);

  my $mapper = Bio::EnsEMBL::Mapper->new('mapped_slice', 'ref_slice');
  my $mapped_slice = Bio::EnsEMBL::MappedSlice->new(
    -ADAPTOR   => $vdb,
    -CONTAINER => $msc,
    -NAME      => $slice->name . "\#strain_$name",
  );

  $mapper->add_map_coordinates(  'mapped_slice',  1, 11, 1, 1, 3574805, 3574815);
  $mapper->add_indel_coordinates('mapped_slice', 12, 19, 1, 1, 3574816, 3574815);
  $mapper->add_map_coordinates(  'mapped_slice', 20, 49, 1, 1, 3574816, 3574845);

  $mapped_slice->add_Slice_Mapper_pair($strain_slice, $mapper);
  push @{ $msc->{'mapped_slices'} }, $mapped_slice;

  my $new_mapper = Bio::EnsEMBL::Mapper->new('ref_slice', 'container');

  $new_mapper->add_map_coordinates(   1, 3574805, 3574815, 1, 'container',  1, 11);
  $new_mapper->add_indel_coordinates( 1, 3574816, 3574815, 1, 'container', 12, 19);
  $new_mapper->add_map_coordinates(   1, 3574816, 3574845, 1, 'container', 20, 49);



  $msc->mapper($new_mapper);
  $msc->container_slice($msc->container_slice->expand(undef, 8, 1));

  foreach (@{$msc->get_all_MappedSlices}) {
    print $_->seq(1), "\n\n";


    my $ref_slice_start = $_->container->ref_slice->start;
    my $ref_slice_end = $_->container->ref_slice->end;
#    print "$ref_slice_start $ref_slice_end\n";
    foreach my $pair (@{$_->get_all_Slice_Mapper_pairs()}) {
      my ($s, $m) = @$pair;
      my $seq = $s->seq(1);
#      print "$seq\n\n";
      
      my $ref_start = 3574816;
      my $ref_end = 3574845;
      foreach my $ms_coord ($_->container->mapper->map_coordinates($_->container->ref_slice->seq_region_name, $ref_start, $ref_end, 1, 'ref_slice')) {
            my $ms_coord_start = $ms_coord->start;
            my $ms_coord_end = $ms_coord->end;
            print "  MS coord $ms_coord start $ms_coord_start end $ms_coord_end\n";
      }

      foreach my $ref_coord ($m->map_coordinates('mapped_slice', 1, CORE::length($seq), $s->strand, 'mapped_slice')) {
        my $ref_slice_seq_name = $_->container->ref_slice->seq_region_name;
        my $ref_coord_start = $ref_coord->start;
        my $ref_coord_end = $ref_coord->end;
        print "Ref coord $ref_coord seq_name $ref_slice_seq_name start $ref_coord_start end $ref_coord_end\n";
        if (!$ref_coord->isa('Bio::EnsEMBL::Mapper::IndelCoordinate') && !$ref_coord->isa('Bio::EnsEMBL::Mapper::Gap')) {
          foreach my $ms_coord ($_->container->mapper->map_coordinates($_->container->ref_slice->seq_region_name, $ref_coord->start, $ref_coord->end, $ref_coord->strand, 'ref_slice')) {
            my $ms_coord_start = $ms_coord->start;
            my $ms_coord_end = $ms_coord->end;
            print "  MS coord $ms_coord start $ms_coord_start end $ms_coord_end\n";
          }
        }       
        print "\n";
      }

    }

  }

}

=begin
http://enssand-01.internal.sanger.ac.uk:9023/Mus_musculus/Location/SequenceAlignment?db=core;r=1:3574805-3574845;v=rs387795911;vdb=variation;vf=78921632
http://enssand-01.internal.sanger.ac.uk:9023/Mus_musculus/Variation/Sample?db=core;r=1:3570888-3572950;v=rs232469908;vdb=variation;vf=43975760
http://enssand-01.internal.sanger.ac.uk:9023/Mus_musculus/Variation/Explore?db=core;r=1:3570888-3572950;source=dbSNP;v=rs240295124;vdb=variation;vf=51839086
http://enssand-01.internal.sanger.ac.uk:9023/Mus_musculus/Variation/Sample?db=core;r=1:3570888-3570950;v=rs228385341;vdb=variation;vf=39871407
http://enssand-01.internal.sanger.ac.uk:9023/Mus_musculus/Variation/Sample?db=core;r=1:3570888-3570950;v=rs223628109;vdb=variation;vf=35091011
http://enssand-01.internal.sanger.ac.uk:9023/Mus_musculus/Variation/Explore?db=core;r=1:3570888-3570950;source=dbSNP;v=rs232469908;vdb=variation;vf=43975760
http://www.ensembl.org/Mus_musculus/Location/SequenceAlignment?db=core;r=1:3570888-3570950;v=rs387795911;vdb=variation;vf=78921632
http://www.ensembl.org/Mus_musculus/Location/SequenceAlignment?db=core;r=1:3574805-3574845;v=rs387795911;vdb=variation;vf=78921632
=end
=cut
