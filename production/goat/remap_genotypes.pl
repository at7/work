use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup/production/ensembl/anja/release_92/goat/variation_qc/ensembl.registry');
my $dbh = $registry->get_DBAdaptor('goat', 'variation')->dbc->db_handle;

# new VCF line
# #CHROM POS ID REF ALT QUAL FILTER INFO FORMAT genotypes

my $vcf_file = '/hps/nobackup/production/ensembl/anja/release_92/goat/MOCH.genus_snps.CHIR1_0.20140928.vcf.gz';
my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);

my @chroms = @{get_chroms('/hps/nobackup/production/ensembl/anja/release_92/goat/MOCH_chroms_list')};

foreach my $chrom (@chroms) {
  my $mappings = update_mappings($chrom);
  my $count = scalar keys %$mappings;
  if ($count > 0) {
    print STDERR "$chrom $count\n";
  }  
}

=begin
$parser->seek(1, 54156000, 54156500);

while ($parser->next) {
  my $reference = $parser->get_reference;
  my @alternatives = @{$parser->get_alternatives};
  my $allele_string = join('/', $reference, @alternatives);
  my $seq_name = $parser->get_seqname;
  my $start = $parser->get_start;
  my $raw_IDs = $parser->get_raw_IDs;
  my @IDs = split(',', $raw_IDs);
  my $qual = $parser->get_raw_score;
  my $filter = $parser->get_raw_filter_results;
  my $info = $parser->get_raw_info;
  my $format = $parser->get_raw_formats;
  my $samples_info = $parser->get_samples_info;
  foreach my $sample (keys %$samples_info) {
    while (my ($from, $to) = each (%{$samples_info->{$sample}})) {
      print join(' ', $raw_IDs, $seq_name, $start, $allele_string, $qual, $filter, $info, $format, $sample, $from, $to), "\n";
    }
  }
}
=end
=cut
sub update_mappings {
  my $seq_region_name = shift;
  my $mappings = {};
  my $sth = $dbh->prepare(qq{
    SELECT subsnp_id, variation_id, seq_region_name_new, seq_region_start_new, allele_string_new
    FROM vcf_variation_moch
    WHERE seq_region_name_old = ?
    AND variation_id IS NOT NULL;
  }, {mysql_use_result => 1});

  $sth->execute($seq_region_name);
  my ($subsnp_id, $variation_id, $seq_region_name_new, $seq_region_start_new, $allele_string_new);
  $sth->bind_columns(\($subsnp_id, $variation_id, $seq_region_name_new, $seq_region_start_new, $allele_string_new));
  while ($sth->fetch) {
    $mappings->{$subsnp_id}->{$variation_id}->{"$seq_region_name_new:$seq_region_start_new"} = $allele_string_new;
  }
  $sth->finish;
  return $mappings;
}

sub get_chroms {
  my $file = shift;
  my @chroms = ();
  my $fh = FileHandle->new($file, 'r');
  while (<$fh>) {
    chomp;
    push @chroms, $_;
  }
  $fh->close;
  return \@chroms;
}
