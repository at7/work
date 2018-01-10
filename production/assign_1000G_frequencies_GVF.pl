use strict;
use warnings;

use FileHandle;
use Compress::Zlib;
#my $fh_in  = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_90/dumps_human/homo_sapiens/Homo_sapiens.gvf.gz', 'r');
#my $gvf_file  = '/hps/nobackup/production/ensembl/anja/release_90/dumps_human_37/gvf/homo_sapiens/Homo_sapiens.gvf.gz';

#my $gvf_file = '/hps/nobackup/production/ensembl/anja/release_90/dumps_90/gvf/homo_sapiens/Homo_sapiens.gvf.gz';
my $gvf_file = '/hps/nobackup/production/ensembl/anja/release_91/dumps_human/gvf/homo_sapiens/homo_sapiens.gvf.gz';

my $fh_in = gzopen($gvf_file, "rb") or die "Error reading $gvf_file: $gzerrno\n";
#my $fh_out = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_90/dumps_human_37/gvf/homo_sapiens/1000GENOMES-phase_3.gvf', 'w');
my $fh_out = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_91/dumps_human/gvf/homo_sapiens/1000GENOMES-phase_3.gvf', 'w');


my $frequencies_chrom = {};

my $prev_chrom = '0';

while ($fh_in->gzreadline($_) > 0) {
  chomp;
  if (/^#/) {
    print $fh_out $_, "\n";       
  } else {
    my @values = split("\t", $_);
    my $chrom = $values[0];
    my $info = $values[8];
    if (!$info) {
      print STDERR $_, "\n";
      next;
    }
    my @info_values = split(';', $info);
    my $rs = '';
    my @alts = ();
    my $ref_seq = '';
    foreach (@info_values) {
      if (/^Dbxref/) {
        my ($db, $name) = split(':');
        $rs = $name;
      }
      if (/^Variant_seq/) {
        @alts = split(',', (split('='))[1]);
      }
      if (/^Reference_seq/) {
        $ref_seq = (split('='))[1];
      }
    }
    if ($chrom ne $prev_chrom) {
      update_chrom($chrom);
    }
    $prev_chrom = $chrom;

    my $id_2_freqs = $frequencies_chrom->{$rs};
    next unless ($id_2_freqs);
    my ($gvf_alleles_string, $prefetched_frequencies) = split("\t", $frequencies_chrom->{$rs});
#EAS_AF=0.3363;EUR_AF=0.4056;AMR_AF=0.3602;SAS_AF=0.4949;AFR_AF=0.4909

    my @gvf_alts = split('/', $gvf_alleles_string);
    shift @gvf_alts;

    my $frequency_lookup = {};

    foreach (split(';', $prefetched_frequencies)) {
      my ($population, $freqs) = split('=', $_);
      my @population_frequencies = split(',', $freqs);

      if (scalar @population_frequencies != scalar @gvf_alts) {
        print STDERR "Different array length for $rs ", $frequencies_chrom->{$rs}, "\n";
      }

      for my $i (0 .. $#gvf_alts) {
        my $allele = $gvf_alts[$i];
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

    $info = $info . ';' . join(';', @updated_frequencies);
    print $fh_out join("\t", $values[0], $values[1], $values[2], $values[3], $values[4], $values[5], $values[6], $values[7], $info), "\n";
  }
}

$fh_in->gzclose(); 
$fh_out->close();


sub update_chrom {
  my $chrom = shift;
  $frequencies_chrom = {};
  print STDERR $chrom, "\n";
  if ($chrom ne 'MT') {
#/hps/nobackup/production/ensembl/anja/1000G_phase3_frequencies_08_05_2017
#    my $fh = FileHandle->new("/hps/nobackup/production/ensembl/anja/1000G_phase3_frequencies_37_31_07_2017/$chrom.txt", 'r');
    my $fh = FileHandle->new("/hps/nobackup/production/ensembl/anja/1000G_phase3_frequencies_08_05_2017/$chrom.txt", 'r');

    while (<$fh>) {
      chomp;
      my ($id, $vcf_alleles, $gvf_alleles, $frequencies) = split("\t", $_);
      my @ids = split(';', $id);
      foreach (@ids) {
        if (/^rs/) {
          $frequencies_chrom->{$_} = "$gvf_alleles\t$frequencies";
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


