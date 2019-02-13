use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -port => 3337,
  -db_version => 95
);

my $species = 'human';

my $slice_adaptor = $registry->get_adaptor($species, 'core', 'slice');

my $dir = '/hps/nobackup2/production/ensembl/anja/gnomad/Genomes/mapping_results/';

my $fh = FileHandle->new("$dir/write_gnomad_exomes_unmapped.txt", 'w');

for my $chrom (1..22, 'X', 'Y') {
  my $vcf_file = "$dir/gnomad.genomes.r2.1.sites.grch38.chr$chrom\_noVEP.vcf.unmap.gz";
  my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);

  my $chrom_slice = $slice_adaptor->fetch_by_region('chromosome', $chrom);
  my $seq_region_id = $chrom_slice->get_seq_region_id;
  my $seq_region_start = $chrom_slice->seq_region_start;
  my $seq_region_end = $chrom_slice->seq_region_end;
  print STDERR "$chrom $seq_region_start $seq_region_end\n";
  $parser->seek($chrom, $seq_region_start, $seq_region_end);
  while ($parser->next) {
    my ($ref, $alts, $info) = (
      $parser->get_reference,
      $parser->get_alternatives,
      $parser->get_info,
    );

    my ($chr, $start, $end, $ids) = (
      $parser->get_seqname,
      $parser->get_raw_start,
      $parser->get_raw_start,
      $parser->get_IDs,
    );
    $end += length($ref) - 1;


    my $is_indel = 0;
    foreach my $alt_allele(@$alts) {
      $is_indel = 1 if length($alt_allele) != length($ref);
    }
    if(scalar @$alts > 1) {
      if($is_indel) {

        # find out if all the alts start with the same base
        # ignore "*"-types
        my %first_bases = map {substr($_, 0, 1) => 1} grep {!/\*/} ($ref, @$alts);

        if(scalar keys %first_bases == 1) {
          $ref = substr($ref, 1) || '-';
          $start++;

          my @new_alts;

          foreach my $alt_allele(@$alts) {
            $alt_allele = substr($alt_allele, 1) unless $alt_allele =~ /\*/;
            $alt_allele = '-' if $alt_allele eq '';
            push @new_alts, $alt_allele;
          }

          $alts = \@new_alts;
        }
      }
    }

    elsif($is_indel) {

      # insertion or deletion (VCF 4+)
      if(substr($ref, 0, 1) eq substr($alts->[0], 0, 1)) {

        # chop off first base
        $ref = substr($ref, 1) || '-';
        $alts->[0] = substr($alts->[0], 1) || '-';

        $start++;
      }
    }

    print $fh join("\t", $seq_region_id, $start, $end, "$ref/".join('/', @$alts), @$ids), "\n";
  }
  $parser->close;
}
$fh->close;


