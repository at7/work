use strict;
use warnings;

#my $dir = '/hps/nobackup2/production/ensembl/anja/release_97/human/dumps/vertebrates/vcf/homo_sapiens/';

my $dir = '/hps/nobackup2/production/ensembl/anja/release_96/';
my $file = "$dir/homo_sapiens_structural_variations.vcf";
my $file_gz = "$dir/homo_sapiens_structural_variations.vcf.gz";

###source=ensembl;version=96;url=http://vertebrates.ensembl.org/homo_sapiens
###reference=ftp://ftp.ensembl.org/pub/release-96/fasta/homo_sapiens/dna/
#my $file = "$dir/homo_sapiens-chr1.vcf";
#run_cmd("sed -i 's#release-96#release-97#' $file");


#run_cmd("sed -i 's#https://vertebrates.ensembl#https://ensembl#' $file");
run_cmd("vcf-sort -t /hps/nobackup2/production/ensembl/anja/ < $file | bgzip > $file_gz");
run_cmd("tabix -f -p vcf $file_gz");

#opendir(DIR, $dir) or die $!;
#while (my $filename_gz = readdir(DIR)) {
#  if ($filename_gz =~ m/\.gz$/) {
#    my $filename = $filename_gz;
#    $filename =~ s/\.gz//;  
#    my $file = "$dir/$filename";
#    my $file_gz = "$dir/$filename_gz";
#    run_cmd("gunzip $file_gz");
#    run_cmd("sed -i 's#https://vertebrates.ensembl#https://ensembl#' $file");
#    run_cmd("vcf-sort -t /hps/nobackup2/production/ensembl/anja/ < $file | bgzip > $file_gz");
#    run_cmd("tabix -f -p vcf $file_gz");
#    print STDERR "$file\n";
#  }
#}
#closedir(DIR);

#my $file = "$dir/homo_sapiens_incl_consequences-chr2.gvf";
#my $file_gz = "$dir/homo_sapiens_incl_consequences-chr2.gvf.gz";
#run_cmd("gunzip $file_gz");
#run_cmd("sed -i 's#http://vertebrates.ensembl#https://ensembl#' $file");
#sed '0,/RE/s//to_that/' file
#run_cmd("sed -i '0,#http://vertebrates.ensembl#s##https://ensembl#' $file");


sub run_cmd {
  my $cmd = shift;
  if (my $return_value = system($cmd)) {
    $return_value >>= 8;
    die "system($cmd) failed: $return_value";
  }
}

