use strict;
use warnings;

use FileHandle;
use JSON;

my $config_file = '/hps/nobackup/production/ensembl/anja/release_90/dumps_human/data_dumps_config.json';

my $fh = FileHandle->new($config_file, 'r');
my $config_text = <$fh>;
my $config = decode_json($config_text);
$fh->close();

#  foreach my $species (keys %$config) {
#    while (my ($key, $value) = each %{$config->{$species}}) {
#      print $key, ' ', $value, "\n";
#    }
#  }

#my $working_dir = "/hps/nobackup/production/ensembl/anja/release_90/dumps_90/gvf";
my $working_dir = "/hps/nobackup/production/ensembl/anja/release_90/dumps_human/gvf";

opendir(DIR, $working_dir) or die $!;
while (my $species_dir = readdir(DIR)) {
  next if ($species_dir =~ /^\./);
  opendir(DIR2, "$working_dir/$species_dir") or die $!;
  while (my $file = readdir(DIR2)) {
    next if ($file =~ /^\.|failed|README|CHECKSUMS/ );
    my $species = ucfirst $species_dir;
    my $dump_type = '';
    print STDERR $file, "\n";
    if ($file =~ /Homo_sapiens_incl_consequences/) {
      $dump_type = 'incl_consequences';
    } elsif ($file =~ /structural_variations/) {
      $dump_type = 'structural_variations';
    } elsif ($file =~ /clinically_associated/) {
      $dump_type = 'clinically_associated';
    } elsif ($file =~ /phenotype_associated/) {
      $dump_type = 'phenotype_associated';
    } elsif ($file =~ /somatic\./) {
      $dump_type = 'somatic';
    } elsif ($file =~ /Homo_sapiens_somatic_incl_consequences/) {
      $dump_type = 'somatic_incl_consequences';
    } else {
      $dump_type = 'generic';
    }
    print STDERR $dump_type, "\n";
    my $args = join(' ', map {"--$_"} @{$config->{$species}->{$dump_type}});
    my $vcf_file = $file;
    $vcf_file  =~ s/gvf\.gz/vcf/;

    my $fh = FileHandle->new("/hps/nobackup/production/ensembl/anja/release_90/dumps_human/rerun_gvf2vcf/$species\_$dump_type.sh", 'w');
    my $dir = '/hps/nobackup/production/ensembl/anja/release_90/dumps_human/rerun_gvf2vcf/';
    print $fh "bsub -J $species\_$dump_type -q production-rh7 -M 5000 -R \"rusage[mem=5000]\" -o $dir/$species\_$dump_type.out -e $dir/$species\_$dump_type.err \\\n";
    print $fh "perl /homes/anja/bin/ensembl-variation/scripts//misc/release/gvf2vcf.pl $args \\\n";
    print $fh "--species $species \\\n";
    print $fh "--registry $dir/ensembl.registry \\\n";
    print $fh "--gvf_file $working_dir/$species_dir/$file \\\n";
    print $fh "--vcf_file $dir/$vcf_file \\\n";
    $fh->close;
  }
  closedir(DIR2);
}
closedir(DIR);

=begin
bsub -J generic_37 -q production-rh7 -M 5000 -R "rusage[mem=5000]" -o $dir/gvf2vcf_generic.out -e $dir/gvf2vcf_generic.err \
perl /homes/anja/bin/ensembl-variation/scripts//misc/release/gvf2vcf.pl --evidence --ancestral_allele --clinical_significance --global_maf --variation_id --allele_string \
--species Homo_sapiens \
--registry /hps/nobackup/production/ensembl/anja/release_90/dumps_human_37/ensembl.registry \
--gvf_file /hps/nobackup/production/ensembl/anja/release_90/dumps_human_37/gvf/homo_sapiens/Homo_sapiens.gvf.gz \
--vcf_file /hps/nobackup/production/ensembl/anja/release_90/dumps_human_37/Homo_sapiens.vcf \

=end
=cut


