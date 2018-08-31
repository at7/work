use strict;
use warnings;
use Bio::DB::Fasta;

my $fasta_files_dir = '/hps/nobackup2/production/ensembl/anja/ancestral_alleles/homo_sapiens_ancestor_GRCh38/';

my $db = Bio::DB::Fasta->new($fasta_files_dir, -reindex => 1); 
my @sequence_ids = $db->get_all_ids;
my %sequence_id_2_chr_number; 

foreach my $sequence_id (@sequence_ids) {
  my @split = split(/:/, $sequence_id);
  $sequence_id_2_chr_number{$split[2]} = $sequence_id;
}

my $chrom = 20;
my $chrom_name = $sequence_id_2_chr_number{$chrom};
my $AA = $db->seq("$chrom_name:111886,111886");
print $AA, "\n";
