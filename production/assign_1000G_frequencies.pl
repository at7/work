use strict;
use warnings;

use FileHandle;
use Compress::Zlib;

#my $fh_in = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_90/dumps_human/vcf/homo_sapiens/Homo_sapiens.vcf.gz', 'r');
my $vcf_file = '/hps/nobackup/production/ensembl/anja/release_90/dumps_human/vcf/homo_sapiens/Homo_sapiens.vcf.gz';

my $fh_out = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_90/dumps_human/vcf/homo_sapiens/1000GENOMES-phase_3.vcf', 'w');
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

    foreach my $population (qw/EAS_AF EUR_AF AMR_AF SAS_AF AFR_AF/) {
      my $lookup = $frequency_lookup->{$population};
      my @ensembl_frequencies = ();
      foreach my $alt (@alts) {
        my $freq = $lookup->{$alt} || 0;
        push @ensembl_frequencies, $freq;
      }
      my $joined_freqs = join(',', @ensembl_frequencies);
      push @updated_frequencies, "$population=$joined_freqs";

    }
    my $info = $values[7];
    $info = $info . ';' . join(';', @updated_frequencies);
    print $fh_out join("\t", $values[0], $values[1], $values[2], $values[3], $values[4], $values[5], $values[6], $info), "\n";
  }

}
$fh_in->gzclose();
$fh_out->close();

sub update_chrom {
  my $chrom = shift;
  $frequencies_chrom = {};
  if ($chrom ne 'MT') {
    my $fh = FileHandle->new("/hps/nobackup/production/ensembl/anja/1000G_phase3_frequencies_08_05_2017/$chrom.txt", 'r'); 
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

=begin
my $fh_in = FileHandle->new('/lustre/scratch110/ensembl/at7/release_85/population_dumps/1000G_vcf/Homo_sapiens.vcf', 'r');
my $fh_out = FileHandle->new('/lustre/scratch110/ensembl/at7/release_85/population_dumps/1000G_vcf/1000GENOMES-phase_3.vcf', 'w');

my $frequencies_chrom = {};

my $prev_chrom = '0';

while (<$fh_in>) {
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
    my $info = $values[7];
    if ($chrom ne $prev_chrom) {
      update_chrom($chrom);
      print STDERR $chrom, "\n";
    }
    my $id_2_allele_string = $frequencies_chrom->{$rs};
    if ($id_2_allele_string) {
      my $allele_string = join('/', $ref, @alts);
      my $freqs = $id_2_allele_string->{$allele_string};
      if ($freqs) {
        $info = $info . ';' . $freqs;
        print $fh_out join("\t", $values[0], $values[1], $values[2], $values[3], $values[4], $values[5], $values[6], $info), "\n";
      } else {
        print STDERR $allele_string, ' ', $_, "\n";
      }
    } 
    $prev_chrom = $chrom;
  }
}

$fh_in->close();
$fh_out->close();

sub update_chrom {
  my $chrom = shift;
  $frequencies_chrom = {};
  if ($chrom ne 'MT') {
    my $fh = FileHandle->new("/lustre/scratch110/ensembl/at7/1000G_phase3_frequencies/$chrom.txt", 'r'); 
    while (<$fh>) {
      chomp;
#      my ($id, $frequencies) = split("\t", $_, 2);
      my ($id, $vcf_alleles, $gvf_alleles, $frequencies) = split("\t", $_);
      my @ids = split(';', $id);
      foreach (@ids) {
        if (/^rs/) {
          $frequencies_chrom->{$_}->{$vcf_alleles} = $frequencies;
        }
      }   
    }
    $fh->close();
  }
  print STDERR scalar keys %$frequencies_chrom, "\n";
}

##INFO=<ID=EAS_AF,Number=A,Type=Float,Description="Allele frequency in the EAS populations">
##INFO=<ID=EUR_AF,Number=A,Type=Float,Description="Allele frequency in the EUR populations">
##INFO=<ID=AFR_AF,Number=A,Type=Float,Description="Allele frequency in the AFR populations">
##INFO=<ID=AMR_AF,Number=A,Type=Float,Description="Allele frequency in the AMR populations">
##INFO=<ID=SAS_AF,Number=A,Type=Float,Description="Allele frequency in the SAS populations">

=end
=cut
