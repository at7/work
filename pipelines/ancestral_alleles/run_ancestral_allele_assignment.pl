use strict;
use warnings;

use Bio::DB::Fasta;
use Bio::DB::HTS::Faidx;
use FileHandle;

use Bio::EnsEMBL::Variation::Utils::AncestralAllelesUtils;

#my $fasta_files_dir = '/hps/nobackup2/production/ensembl/anja/release_99/human/ancestral_alleles/compara_data/homo_sapiens_ancestor.fa';
#my $fasta_files_dir = '/hps/nobackup2/production/ensembl/anja/release_99/human/ancestral_alleles/compara_data/homo_sapiens_ancestor_GRCh38/';

my $fasta_files_dir = '/hps/nobackup2/production/ensembl/anja/release_99/human/ancestral_alleles/compara_data/ancestral_fasta.fa';

my $fasta_db = Bio::DB::HTS::Faidx->new($fasta_files_dir);
#my $fasta_db = Bio::DB::Fasta->new($fasta_files_dir);

my $ancestra_allele_utils = Bio::EnsEMBL::Variation::Utils::AncestralAllelesUtils->new(-fasta_db => $fasta_db);

my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_99/human/ancestral_alleles/vf_test', 'r');
my $out = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_99/human/ancestral_alleles/vf_test.out', 'w');
while (<$fh>) {
  chomp;
  my ($vf_id, $chrom, $start, $end, $strand, $old_aa) = split /\s+/;
  my $aa = $ancestra_allele_utils->assign_ancestral_allele($chrom, $start, $end);
  if ($aa) {
    print $out "$aa\n"; 
  }
}
$fh->close;
$out->close;
