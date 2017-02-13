use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;
use Bio::EnsEMBL::Registry;
use POSIX;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

my $species = 'homo_sapiens';

my $slice_adaptor = $registry->get_adaptor($species, 'core', 'slice');

my $fh = FileHandle->new('hapmap_input', 'w');

foreach my $chrom (1..22, 'X', 'Y') {
  my $vcf_file = ".vcf.gz";
  my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);

  my $chrom_slice = $slice_adaptor->fetch_by_region('chromosome', $chrom);
  my $length = $chrom_slice->length;
  foreach my $percent (0.25, 0.5, 0.75) {
    my $coord_start = ceil($length * $percent);
    my $coord_end = $coord_start + 100;
    $parser->seek($chrom, $coord_start, $coord_end);
    while ($parser->next) {
      my $ids = $parser->get_IDs->[0];
      print $fh "$ids\n";
    }
  }
  $parser->close;
}
$fh->close;
=begin
my $chrom = $ENV{'LSB_JOBINDEX'};

if ($chrom == 23) {
  $chrom = 'X';
}
if ($chrom == 24) {
  $chrom = 'Y';
}

#my $vcf_file = "ftp://ftp.ensembl.org/pub/variation_genotype/homo_sapiens/ALL.chr$chrom.phase3_shapeit2_mvncall_integrated_v3plus_nounphased.rsID.genotypes.GRCh38_dbSNP.vcf.gz";

my $vcf_file = "ftp://ftp.ensembl.org/pub/grch37/release-82/variation/vcf/homo_sapiens/1000GENOMES-phase_3-genotypes/ALL.chr$chrom.phase3_shapeit2_mvncall_integrated_v3plus_nounphased.rsID.genotypes.vcf.gz";

my $fh_out = FileHandle->new("/lustre/scratch110/ensembl/at7/grch37/1000G_phase3_frequencies/$chrom.txt", 'w');

my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);
$parser->seek($chrom, 1);
while ($parser->next) {
  my $ids = join(',', @{$parser->get_IDs});

  my $ref = $parser->get_reference;
  my $vcf_alt = $parser->get_alternatives;
  my $alt = join(',', @$vcf_alt);

  my $vcf_alleles = "$ref/" . join('/', @$vcf_alt);

  my ($is_indel, $is_sub, $ins_count, $total_count);
  foreach my $alt_allele(split ',', $alt) {
      $is_indel = 1 if $alt_allele =~ /^[DI]/;
      $is_indel = 1 if length($alt_allele) != length($ref);
      $is_sub = 1 if length($alt_allele) == length($ref);
      $ins_count++ if length($alt_allele) > length($ref);
      $total_count++;
  }


  if($alt =~ /\,/) {
    if($is_indel) {
        my @alts;

        # find out if all the alts start with the same base
        # ignore "*"-types
        my %first_bases = map {substr($_, 0, 1) => 1} grep {!/\*/} ($ref, split(',', $alt));

        if(scalar keys %first_bases == 1) {
            $ref = substr($ref, 1) || '-';

            foreach my $alt_allele(split ',', $alt) {
                $alt_allele = substr($alt_allele, 1) unless $alt_allele =~ /\*/;
                $alt_allele = '-' if $alt_allele eq '';
                push @alts, $alt_allele;
            }
        }
        else {
            push @alts, split(',', $alt);
        }

        $alt = join "/", @alts;
    }

    else {
        # for substitutions we just need to replace ',' with '/' in $alt
        $alt =~ s/\,/\//g;
    }
  }

  elsif($is_indel) {

      # insertion or deletion (VCF 4+)
      if(substr($ref, 0, 1) eq substr($alt, 0, 1)) {

          # chop off first base
          $ref = substr($ref, 1) || '-';
          $alt = substr($alt, 1) || '-';

      }
  }


  my @frequencies = ();


  my $info = $parser->get_info;

  foreach my $key (keys %$info) {
    my $value = $info->{$key};
    if (grep {$key =~ /^$_/} qw/AMR_AF AFR_AF EUR_AF SAS_AF EAS_AF/) {
      push @frequencies, "$key=$value";
    }
  }
  my $joined_frequencies = join(';', @frequencies);

  print $fh_out join("\t", $ids, $vcf_alleles, "$ref/$alt", $joined_frequencies), "\n";
}
$parser->close();
$fh_out->close();

=end
=cut
