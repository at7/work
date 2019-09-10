use strict;
use warnings;

use Bio::EnsEMBL::Variation::Utils::Sequence qw(trim_right get_matched_variant_alleles);
use Data::Dumper;


#get_matched_variant_alleles

#trim_right

#my @alleles = qw/TGTGTGTGTGTGT TGTGTGTGT TGTGTGTGTGT TGTGTGTGTGTGTGT/;
#@alleles = qw/GAAGA GA/;
#@alleles = @{trim_right(\@alleles)};
#unshift @alleles, '-' if scalar @alleles == 1;




#CCCCCCC/CCCCCC/CCCCCCCC/CCCCCCCCCC from 1000Genomes -/CCC
#$VAR1 = [
#          {
#            'a_index' => 2,
#            'a_allele' => 'CCCCCCCCCC',
#            'b_allele' => 'CCC',
#            'b_index' => 0
#         }
#        ];
#                    a_allele => $matched_allele_from_var_a,
#                    a_index  => $index_of_matched_allele_in_b_alts,
#                    b_allele => $matched_allele_from_var_b,
#                    b_index  => $index_of_matched_allele_in_b_alts,

#    foreach my $orig_a_alt(@alts) {
#    #      foreach my $direction(@{_get_trim_directions($ref_seq, $orig_a_alt)}) {
#    #        my ($ref, $alt, $pos) = @{trim_sequences($ref_seq, $alt, undef, undef, 1, $direction)};
#    #        $minimised_alleles{$alt} = 1;
#    #      }
#    #    }
#
#    #  @alts = keys %$minimised_alleles;
#
#
#    #    @alts = @{trim_right(\@alts)};
#
#    #    my %first_bases = map {substr($_, 0, 1) => 1} grep {!/\*/} (@alts);
#    #    $ref_seq = shift @alts;
#    #    if(scalar keys %first_bases == 1) {
#    #      $ref_seq = substr($ref_seq, 1) || '-';
#    #      my @new_alts;
#    #      foreach my $alt_allele(@alts) {
#    #        $alt_allele = substr($alt_allele, 1);
#    #        $alt_allele = '-' if $alt_allele eq '';
#    #        push @new_alts, $alt_allele;
#    #      }
#    #      @alts = @new_alts;
#    #    }
#


my $var_a = {allele_string => 'CCCCCCC/CCCCCC/CCCCCCCC/CCCCCCCCCC', pos => 1};
my $var_b = {allele_string => '-/CCC', pos => 1};

$var_a = {allele_string => 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAA/AAAAAAAAAAAAA/AAAAAAAAAAAAAAA/AAAAAAAAAAAAAAAAA/AAAAAAAAAAAAAAAAAA/AAAAAAAAAAAAAAAAAAAA/AAAAAAAAAAAAAAAAAAAAA/AAAAAAAAAAAAAAAAAAAAAA/AAAAAAAAAAAAAAAAAAAAAAA/AAAAAAAAAAAAAAAAAAAAAAAA/AAAAAAAAAAAAAAAAAAAAAAAAA/AAAAAAAAAAAAAAAAAAAAAAAAAA/AAAAAAAAAAAAAAAAAAAAAAAAAAA/AAAAAAAAAAAAAAAAAAAAAAAAAAAA/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', pos => 1};
$var_a = {allele_string => 'TCTGAACT/TCT', pos => 1};
$var_b = {allele_string =>    'TCTGAA/T', pos => 1 };

my $matched_alleles = get_matched_variant_alleles($var_a, $var_b);

print Dumper $matched_alleles;
