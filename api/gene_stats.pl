use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;
use POSIX;
my $reg = 'Bio::EnsEMBL::Registry';

$reg->load_all('/hps/nobackup2/production/ensembl/anja/release_95/human/variation_consequence_38/ensembl.registry');

my $gene_adaptor = $reg->get_adaptor('human', 'core', 'gene');


my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/human/variation_consequence_38/statistics/job', 'r'); 
my $fh_out = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/human/variation_consequence_38/statistics/job_stats_all_hours', 'w'); 

while (<$fh>) {
  chomp;
  next if /^analysis_id/;
  my ($analysis_id, $input_id, $runtime_msec) = split/\t/;
  my $hours = floor($runtime_msec/3.6e+6);
    my $gene = $gene_adaptor->fetch_by_stable_id($input_id);
    if (!defined $gene) {
      print STDERR "$input_id\n";
    } else {
      my $gene_length = $gene->length;
      my $transcripts = $gene->get_all_Transcripts;
      my $number_of_transcripts = scalar @$transcripts;
      my $total_length = 0;
      foreach my $transcript (@$transcripts) {
        my $length = $transcript->length;    
        $total_length += $length;
      }
      my $avg_transcript_length = floor($total_length / $number_of_transcripts);
      print $fh_out join("\t", $analysis_id, $gene_length, $avg_transcript_length, $number_of_transcripts, $runtime_msec, $hours, $input_id), "\n";
    }
}

$fh->close;
$fh_out->close;

