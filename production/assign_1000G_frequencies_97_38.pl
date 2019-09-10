use strict;
use warnings;

use FileHandle;
use Compress::Zlib;
use Bio::EnsEMBL::Variation::Utils::Sequence qw(trim_right trim_sequences get_matched_variant_alleles);
my $chrom = $ENV{'LSB_JOBINDEX'};

if ($chrom == 23) {
  $chrom = 'X';
}
if ($chrom == 24) {
  $chrom = 'Y';
}

#my $fh_in = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_90/dumps_human/vcf/homo_sapiens/Homo_sapiens.vcf.gz', 'r');
#my $vcf_file = '/hps/nobackup/production/ensembl/anja/release_90/dumps_human/vcf/homo_sapiens/Homo_sapiens.vcf.gz';
#my $vcf_file = '/hps/nobackup/production/ensembl/anja/release_92/human/grch37/vcf2/homo_sapiens/homo_sapiens.vcf.gz';
#my $vcf_file = "/hps/nobackup2/production/ensembl/anja/release_94/human/grch37/dumps/vcf/homo_sapiens/homo_sapiens-chr$chrom.vcf.gz";
#my $vcf_file = "/hps/nobackup2/production/ensembl/anja/release_94/human/grch37/dumps/vcf/homo_sapiens/homo_sapiens-chr$chrom.vcf.gz";
my $vcf_file = "/hps/nobackup2/production/ensembl/anja/release_98/human/dumps/vertebrates/variation/vcf/homo_sapiens/homo_sapiens-chr$chrom.vcf.gz";

my $fh_out = FileHandle->new("/hps/nobackup2/production/ensembl/anja/release_98/human/dumps/population_dumps/vcf/homo_sapiens/1000GENOMES-phase_3_chrom$chrom.vcf", 'w');

my $fh_in = gzopen($vcf_file, "rb") or die "Error reading $vcf_file: $gzerrno\n";

my $frequencies_chrom = {};
my $prev_chrom = '0';

while ($fh_in->gzreadline($_) > 0) {
  chomp;
  if (/^#/) {
    if (/^#CHROM/) {
      print $fh_out "##INFO=<ID=EAS_AF,Number=A,Type=Float,Description=\"Allele frequency in the EAS populations\">\n";
      print $fh_out "##INFO=<ID=EUR_AF,Number=A,Type=Float,Description=\"Allele frequency in the EUR populations\">\n";
      print $fh_out "##INFO=<ID=AFR_AF,Number=A,Type=Float,Description=\"Allele frequency in the AFR populations\">\n";
      print $fh_out "##INFO=<ID=AMR_AF,Number=A,Type=Float,Description=\"Allele frequency in the AMR populations\">\n";
      print $fh_out "##INFO=<ID=SAS_AF,Number=A,Type=Float,Description=\"Allele frequency in the SAS populations\">\n";
      print $fh_out join("\t", ('#CHROM', 'POS', 'ID', 'REF', 'ALT', 'QUAL', 'FILTER', 'INFO')), "\n";
    } else {
      print $fh_out $_, "\n";       
    }
  } else {
    my @values = split("\t", $_);
    my $chrom = $values[0];
    my $rs = $values[2];
    my $ref = $values[3]; 
    my @alts = split(',', $values[4]);

    if ($chrom ne $prev_chrom) {
      update_chrom($chrom);
      print STDERR $chrom, "\n";
    }
    $prev_chrom = $chrom;

    next unless ($frequencies_chrom->{$rs});

#    if (scalar @alts > 1) {
#      print STDERR "More than one alt $rs\n";
#    } 

    my ($vcf_alleles_string, $prefetched_frequencies) = split("\t", $frequencies_chrom->{$rs});
#EAS_AF=0.3363;EUR_AF=0.4056;AMR_AF=0.3602;SAS_AF=0.4949;AFR_AF=0.4909

    my @vcf_alts = split('/', $vcf_alleles_string); 
    shift @vcf_alts;

    my $frequency_lookup = {};

    foreach (split(';', $prefetched_frequencies)) {
      my ($population, $freqs) = split('=', $_);
      my @population_frequencies = split(',', $freqs);

      if (scalar @population_frequencies != scalar @vcf_alts) {
        print STDERR "Different array length for $rs ", $frequencies_chrom->{$rs}, "\n";
      }      

      for my $i (0 .. $#vcf_alts) {
        my $allele = $vcf_alts[$i];
        my $frequency = $population_frequencies[$i];
        $frequency_lookup->{$population}->{$allele} = $frequency;
      }      
    }

    my @updated_frequencies = ();
    my $all_freqs_are_null = 1;
    my $before =  $ref . '/' . join('/', @alts);

    my $dbSNP_alleles_string = $ref . '/' .join('/', @alts);

    my $var_a = {allele_string => $dbSNP_alleles_string, pos => 1};
    my $var_b = {allele_string => $vcf_alleles_string, pos => 1};
    my $matched_alleles = get_matched_variant_alleles($var_a, $var_b);
    my $matched_alleles_mapping = {};
    foreach my $hash (@{$matched_alleles}) {
      my $a_allele = $hash->{'a_allele'};
      my $b_allele = $hash->{'b_allele'};
      $matched_alleles_mapping->{$a_allele} = $b_allele;
    }


    foreach my $population (qw/EAS_AF EUR_AF AMR_AF SAS_AF AFR_AF/) {
      my $lookup = $frequency_lookup->{$population};
      my @ensembl_frequencies = ();
      foreach my $alt (@alts) {
        my $matched_alt = $matched_alleles_mapping->{$alt} || 'NA';
        my $freq = $lookup->{$matched_alt} || 0;
        $all_freqs_are_null = 0 if ($freq > 0);
        push @ensembl_frequencies, $freq;
      }
      my $joined_freqs = join(',', @ensembl_frequencies);
      push @updated_frequencies, "$population=$joined_freqs";

    }
    my $info = $values[7];
    $info = $info . ';' . join(';', @updated_frequencies);
    print $fh_out join("\t", $values[0], $values[1], $values[2], $values[3], $values[4], $values[5], $values[6], $info), "\n";
    if ($all_freqs_are_null) {
      print STDERR "$rs from dumps: $before from 1000Genomes $vcf_alleles_string\n";
    }
  }

}
$fh_in->gzclose();
$fh_out->close();

sub update_chrom {
  my $chrom = shift;
  $frequencies_chrom = {};
  if ($chrom ne 'MT') {
#    my $fh = FileHandle->new("/hps/nobackup2/production/ensembl/anja/1000G_phase3_frequencies_37_31_07_2017/$chrom.txt", 'r'); 
    my $fh = FileHandle->new("/hps/nobackup2/production/ensembl/anja/1000G_phase3_frequencies_08_05_2017/$chrom.txt", 'r');
    while (<$fh>) {
      chomp;
      my ($id, $vcf_alleles, $gvf_alleles, $frequencies) = split("\t", $_);
      my @ids = split(';', $id);
      foreach (@ids) {
        if (/^rs/) {
          $frequencies_chrom->{$_} = "$vcf_alleles\t$frequencies";
        }
      }   
    }
    $fh->close();
  }
  print STDERR scalar keys %$frequencies_chrom, "\n";
}


