use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;

my $vcf_file = '/hps/nobackup/production/ensembl/anja/release_92/goat/merge/merged.vcf.gz';
my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);


my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/goat/merge/cmp_gts_chrom1_old_assembly', 'w');

my $chrom = 1;

  $parser->seek($chrom, 1);
  while ($parser->next) {
    my $seq_name = $parser->get_seqname;
    my $start = $parser->get_start;
    my $reference = $parser->get_reference;
    my @alternatives = @{$parser->get_alternatives};
    my $allele_string = join('/', $reference, @alternatives);
    my @IDs = split(',', $parser->get_raw_IDs);
#    foreach my $id (@IDs) {
#      print $fh join("\t", $seq_name, $start, $allele_string, $id), "\n";
#    }
    my $sample_genotypes = $parser->get_samples_genotypes;
    my $counts = {};
    my $sample_with_gt_counts = 0;
    foreach my $sample (keys %$sample_genotypes) {
      print STDERR $sample, "\n";
      if ($sample =~ /^MOCH/) {
        $counts->{MOCH}->{$sample_genotypes->{$sample}}++;
      } else {
        $counts->{ITCH}->{$sample_genotypes->{$sample}}++;
      }
    }
    my @moch_gts = ();
    my @itch_gts = ();

    foreach my $gt (keys %{$counts->{MOCH}}) {
      push @moch_gts, "$gt:$counts->{MOCH}->{$gt}";
    }
    foreach my $gt (keys %{$counts->{ITCH}}) {
      push @itch_gts, "$gt:$counts->{ITCH}->{$gt}";
    }


    foreach my $id (@IDs) {
      print $fh join("\t", $id, 'MOCH', @moch_gts, 'ITCH', @itch_gts), "\n";
    }
  }
$fh->close;
