use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;
use Bio::EnsEMBL::Registry;
use POSIX;
use Bio::DB::Fasta;

my $registry = 'Bio::EnsEMBL::Registry';


$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);
my $species = 'human';
my $dir = '/hps/nobackup2/production/ensembl/anja/release_96/human/remap_gnomad/';
my $fh = FileHandle->new("$dir/multi_mapping_results.txt", 'r');

my $mapped_features = {};

while (<$fh>) {
  chomp;
 #sr.name, vf.seq_region_start, vf.seq_region_end, vf.allele_string, vf.variation_name, vf.variation_id 
  my ($chrom, $seq_region_id, $start, $end, $allele_string, $variation_name, $variation_id) = split/\t/;
  push @{$mapped_features->{$variation_id}->{$variation_name}}, {
    chrom => $chrom,
    seq_region_id => $seq_region_id,
    start => $start,
    end => $end,
    allele_string => $allele_string,
    variation_name => $variation_name,
  }
}

$fh->close;

my $fh_mappings = FileHandle->new("$dir/gnomad_exomes_unmapped_mappings.txt", 'w');
my $fh_no_mappings = FileHandle->new("$dir/gnomad_exomes_unmapped_no_mappings.txt", 'w');
my $variation_adaptor = $registry->get_adaptor($species, 'variation', 'variation');
my $vfa = $registry->get_adaptor($species, 'variation', 'variationfeature');

foreach my $variation_id (keys %$mapped_features) {
  foreach my $variation_name (keys %{$mapped_features->{$variation_id}}) {
    my @mapped_vfs = @{$mapped_features->{$variation_id}->{$variation_name}};
    if ($variation_name =~ /^rs/) {
      my $variation = $variation_adaptor->fetch_by_name($variation_name);
      if (!$variation) {
        print $fh_no_mappings "$variation_id\t$variation_name\tVariant identifier not in 95 variation DB\n";
        next
      }
      my $vfs = $variation->get_all_VariationFeatures;
      if (scalar @$vfs == 0) {
        print $fh_no_mappings "$variation_id\t$variation_name\tNo mappings for variant identifier in 95 variation DB\n";
        next
      }
      foreach my $vf (grep { $_->slice->is_chromosome } @$vfs) {
        my $vf_chrom = $vf->seq_region_name;
        my $vf_start = $vf->seq_region_start;
        my $vf_end = $vf->seq_region_end;
        my $vf_strand = $vf->seq_region_strand;
        my $vf_allele_string = $vf->allele_string;
        my @match = grep {$_->{chrom} eq $vf_chrom && $_->{start} == $vf_start && $_->{end} == $vf_end } @mapped_vfs;
        if (scalar @match == 1) {
          print_mapping_result($match[0]);
        } elsif (scalar @match == 0) {
          print $fh_no_mappings "$variation_id\t$variation_name\tNo matching variation feature from database\n";
        } else {
          print $fh_no_mappings "More than one mapped VF from DB by id $variation_id $variation_name\n";
        }
      }
    } else {
      my @match = ();
      my @fetched_vfs = ();
      foreach (@mapped_vfs) {
        my @vfs = @{$vfa->_fetch_all_by_coords($_->{seq_region_id}, $_->{start}, $_->{end}, 0)};
        if (scalar @vfs > 0) {
          push @match, $_; 
          push @fetched_vfs, @vfs;
        } 
      }
      if (scalar @fetched_vfs > 0) {
        # check that coords are the same for all VFs
        my $count = {};
        $count->{$_->seq_region_name . '_' . $_->seq_region_start . '_' . $_->seq_region_end} = 1 for (@fetched_vfs); 
        if (scalar keys %$count == 1) {
          print_mapping_result($match[0]);
        } else {
          print $fh_no_mappings "More than one mapped VF from DB by location $variation_id $variation_name\n";
          foreach my $vf (@fetched_vfs) {
            print $fh_no_mappings "    >", join("\t", $vf->seq_region_name, $vf->seq_region_start, $vf->seq_region_end, $vf->allele_string, $vf->variation_name), "\n";
          }
        }
      } else {
        print $fh_no_mappings "No mapping from DB by location $variation_id $variation_name\n";
      }
    }
  }
}

$fh_mappings->close;
$fh_no_mappings->close;

sub print_mapping_result {
  my $remapped_vf = shift;
  print $fh_mappings join("\t", $remapped_vf->{chrom}, $remapped_vf->{start}, $remapped_vf->{end}, $remapped_vf->{allele_string}, $remapped_vf->{variation_name}), "\n";
}


