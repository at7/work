use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;


my $file = '/hps/nobackup/production/ensembl/anja/release_96/vervet/samples';
my $fh = FileHandle->new($file, 'w');

my $vcf_file = "ftp://ftp.sra.ebi.ac.uk/vol1/ERZ479/ERZ479238/Svardal_et_al_2017_vervet_monkey_SNPs_incl_rhesus_macaque_diff_SnpEff_ensembl_1.1.78_CAE22.vcf.gz";

my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);

my $samples = $parser->get_samples;
foreach my $sample (@$samples) {
  print $fh $sample, "\n";
}

$parser->close;
$fh->close;

