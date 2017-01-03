use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::MappedSliceContainer;
use Bio::EnsEMBL::Variation::DBSQL::StrainSliceAdaptor;
use Data::Dumper;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
-host => 'ensembldb.ensembl.org',
-user => 'anonymous'
);

my $mapper = Bio::EnsEMBL::Mapper->new('mapped_slice', 'ref_slice');

$mapper->add_map_coordinates(  'mapped_slice',  1, 5, 1, 1, 3570888, 3570892);
$mapper->add_indel_coordinates('mapped_slice', 6, 5, 1, 1, 3570893, 3570906);
$mapper->add_map_coordinates(  'mapped_slice', 6, 49, 1, 1, 3570907, 3570950);

my $new_mapper = Bio::EnsEMBL::Mapper->new('ref_slice', 'container');

$new_mapper->add_map_coordinates(   1, 3570888, 3570906, 1, 'container',  1, 19);
$new_mapper->add_indel_coordinates( 1, 3570907, 3570906, 1, 'container', 20, 20);
$new_mapper->add_map_coordinates(   1, 3570907, 3570950, 1, 'container', 21, 64);


my $seq_length = 49;
my $strand = 1;
my $seq_region_name = 1;

foreach my $ref_coord ($mapper->map_coordinates('mapped_slice', 1, $seq_length, $strand, 'mapped_slice')) {
  my $ref_coord_start = $ref_coord->start;
  my $ref_coord_end = $ref_coord->end;
  print "Ref coord $ref_coord start $ref_coord_start end $ref_coord_end\n";
  if (!$ref_coord->isa('Bio::EnsEMBL::Mapper::IndelCoordinate')) {
    foreach my $ms_coord ($new_mapper->map_coordinates($seq_region_name, $ref_coord->start, $ref_coord->end, $ref_coord->strand, 'ref_slice')) {
      my $ms_coord_start = $ms_coord->start;
      my $ms_coord_end = $ms_coord->end;
      print "  MS coord $ms_coord start $ms_coord_start end $ms_coord_end\n";
    }
  }
}


=begin
TCATCATATCATATCATAT   ATATCATATCATATATATCATATCATATCATATCATCCCTTAGA  -> ref_slice

TCATCATATCATATCATAT - ATATCATATCATATATATCATATCATATCATATCATCCCTTAGA  -> container 
tcatc--------------   atatcatatcatatatatcatatcatatcatatcatccCttaga  -> mapped_slice


What I need is this however:

TCATCATATCATATCATAT - ATATCATATCATATATATCATATCATATCATATCATCCCTTAGA  -> container 
tcatc-------------- - atatcatatcatatatatcatatcatatcatatcatccCttaga  -> mapped_slice

=end
=cut
