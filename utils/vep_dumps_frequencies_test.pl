use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;
use Bio::EnsEMBL::Registry;
use POSIX;
use Bio::EnsEMBL::Variation::Utils::Sequence qw(trim_sequences get_matched_variant_alleles);
use Scalar::Util qw(looks_like_number);
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

my $species = 'human';

my $slice_adaptor = $registry->get_adaptor($species, 'core', 'slice');
my $variation_adaptor = $registry->get_adaptor($species, 'variation', 'variation');



my $vcf_file = "/nfs/production/panda/ensembl/variation/data/dump_vep/1KG.phase3.GRCh38.vcf.gz";
my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);

my $chrom = 10;
my $seq_region_start = 103908421;
my $seq_region_end = 103908422;

my $variation = $variation_adaptor->fetch_by_name('rs71019701');
my $v = $variation->get_all_VariationFeatures->[0];

$parser->seek($chrom, $seq_region_start, $seq_region_end);
while ($parser->next) {
  my $vcf_ref  = $parser->get_reference;
  my $vcf_pos  = $parser->get_raw_start;
  my @vcf_alts = @{$parser->get_alternatives};
  print STDERR "$vcf_ref $vcf_pos\n";

  my $matches = get_matched_variant_alleles(
            {
              allele_string => $v->{allele_string},
              pos           => $v->{start},
              strand        => $v->{strand},
            },
            {
              ref  => $vcf_ref,
              alts => \@vcf_alts,
              pos  => $vcf_pos,
            }
          );

  print scalar @$matches, "\n";
  my %allele_map = map {$_->{b_index} => $_->{a_allele}} @$matches;

  print join(', ', values %allele_map), "\n";
  my $info =  $parser->get_info;
#  foreach my $key (keys %$info) {
#    print $key, ' ', $info->{$key}, "\n";
#  }
  my $info_prefix = '';
  my $info_suffix = '';
  my $tmp_f;
  if(exists($info->{$info_prefix.'AF'.$info_suffix})) {
    my $f = $info->{$info_prefix.'AF'.$info_suffix};
    my @split = split(',', $f);
    $tmp_f = join(',',
    map {$allele_map{$_}.':'.($split[$_] == 0 ? 0 : sprintf('%.4g', $split[$_]))}
    grep {$allele_map{$_}}
    grep {looks_like_number($split[$_])}
    0..$#split
    );
  }
  print $tmp_f, "\n";

}
$parser->close;



