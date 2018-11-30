use strict;
use warnings;

use Bio::EnsEMBL::Variation::Utils::Sequence qw(get_matched_variant_alleles trim_sequences);
use Data::Dumper;


my $matched_alleles = get_matched_variant_alleles(
  {
    allele_string => 'AC/A',
    pos => 3,
    strand => 1
  },
  {
    allele_string => 'C/-',
    pos => 4,
    strand => 1
  }
);

print Dumper($matched_alleles);


 my ($new_ref, $new_alt, $new_start) = @{trim_sequences('AC', 'A', 1, 1, 1)};

print "$new_ref $new_alt $new_start\n";
