use strict;
use warnings;

use FileHandle;

use Bio::EnsEMBL::Registry;

use Bio::EnsEMBL::Variation::Utils::Sequence qw(get_3prime_seq_offset trim_sequences);

use Bio::EnsEMBL::Variation::Utils::VEP qw(parse_line get_slice);

my $registry = 'Bio::EnsEMBL::Registry';


$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

my $registry_file = 'ensembl.registry';
my $species = 'homo_sapiens';

$registry->load_all($registry_file);

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

my $population_adaptor = $vdba->get_PopulationAdaptor;
my $variation_adaptor = $vdba->get_VariationAdaptor;
my $vfa = $vdba->get_VariationFeatureAdaptor;

my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_90/human/ESP/esp_89_38', 'r');
while (<$fh>) {
  chomp;
  my @values = split/\s/;
  my $variant_name = $values[4];

  my $variation = $variation_adaptor->fetch_by_name($variant_name);
  my $vfs = $variation->get_all_VariationFeatures;

  my $vf = $vfs->[0];
  my @alleles = split('/', $vf->allele_string);
  my $ref_allele = shift @alleles;

  my $vf_start = $vf->seq_region_start;
  my $vf_end = $vf->seq_region_end;

  foreach my $alt_allele (@alleles) {
    my $allele_strings = {};  
    my $trim_orientation = {};
    foreach my $end_first (0, 1) {
      my $trim_result = trim_sequences($ref_allele, $alt_allele, $vf->seq_region_start, $vf->seq_region_end, 1, $end_first);
      my $new_ref = $trim_result->[0];
      my $new_alt = $trim_result->[1];
      my $new_start = $trim_result->[2];
      my $new_end = $trim_result->[3];
      my $changed = $trim_result->[4];
      my $existing_vfs = $vfa->_fetch_all_by_coords($vf->slice->get_seq_region_id, $new_start, $new_end, 0);
      $allele_strings->{"$new_ref/$new_alt/$new_start/$new_end"} = $existing_vfs;
      if ($end_first) {
        $trim_orientation->{"$new_ref/$new_alt/$new_start/$new_end"} = 'end_first';
      } else {
        $trim_orientation->{"$new_ref/$new_alt/$new_start/$new_end"} = 'start_first';
      }
    }

    if (scalar keys %$allele_strings > 1 ) {
      print STDERR $vf->variation_name, "\n";
      print STDERR "$ref_allele/$alt_allele\n";


      foreach my $key (keys %$allele_strings) {
        my $existing_vfs = $allele_strings->{$key};
        print STDERR " ", $key, ' ', $trim_orientation->{$key}, "\n";
        foreach my $evf (@$existing_vfs) {
          print STDERR " ", $evf->variation_name, "\n";
        }
      }
      print STDERR "\n\n";
    }
  }
}       
$fh->close;


sub _get_flank_seq{
  my $vf = shift;
  # Get the underlying slice and sequence
  my $ref_slice = $vf->{slice};
  my $add_length = 100;  ## allow at least 100 for 3'shifting
  my @allele = split(/\//, $vf->allele_string());
  foreach my $al (@allele) { ## alleles be longer
    if(length($al) > $add_length){
      $add_length = length $al ;
    }
  }
  my $seq_start =  $vf->start() - $add_length;
  my $seq_end   =  $vf->end() + $add_length;

  ## variant position relative to flank
  my $ref_start = $add_length;
  my $ref_end   = $add_length + $vf->end() - $vf->start();

  # Should we be at the beginning of the sequence, adjust the coordinates to not cause an exception
  if ($seq_start < 0) {
    $ref_start += $seq_start;
    $ref_end   += $seq_start;
    $seq_start  = 0;
  }
  my $flank_seq = $ref_slice->subseq($seq_start + 1, $seq_end, 1);
  return ($flank_seq, $ref_start, $ref_end );
}
