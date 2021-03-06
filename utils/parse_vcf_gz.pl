use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;


my $chrom = $ENV{'LSB_JOBINDEX'};

if ($chrom == 23) {
  $chrom = 'X';
}
if ($chrom == 24) {
  $chrom = 'Y';
}


#my $vcf_file = "ftp://ftp.ensembl.org/pub/variation_genotype/homo_sapiens/ALL.chr$chrom.phase3_shapeit2_mvncall_integrated_v3plus_nounphased.rsID.genotypes.GRCh38_dbSNP.vcf.gz";

#my $vcf_file = "http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/supporting/GRCh38_positions/ALL.chr$chrom\_GRCh38.genotypes.20170504.vcf.gz";

my $vcf_file = "ftp://ftp.ensembl.org/pub/data_files/homo_sapiens/GRCh37/variation_genotype/ALL.chr$chrom.phase3_shapeit2_mvncall_integrated_v3plus_nounphased.rsID.genotypes.vcf.gz";

#my $vcf_file = "ftp://ftp.ensembl.org/pub/grch37/release-82/variation/vcf/homo_sapiens/1000GENOMES-phase_3-genotypes/ALL.chr$chrom.phase3_shapeit2_mvncall_integrated_v3plus_nounphased.rsID.genotypes.vcf.gz";

#my $fh_out = FileHandle->new("/lustre/scratch110/ensembl/at7/grch37/1000G_phase3_frequencies/$chrom.txt", 'w');

my $fh_out = FileHandle->new("/hps/nobackup/production/ensembl/anja/1000G_phase3_frequencies_37_31_07_2017/$chrom.txt", 'w');

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


