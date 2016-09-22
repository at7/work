use strict;
use warnings;


use FileHandle;


my $transcripts = {};
my $transcripts_fh = FileHandle->new('/lustre/scratch110/ensembl/at7/release_85/human/updated_transcript_ids', 'r');
while (<$transcripts_fh>) {
  chomp;
  $transcripts->{$_} = 1;
}
$transcripts_fh->close();

my $fh = FileHandle->new('/lustre/scratch110/ensembl/at7/release_85/human/transcript_variation_no_miRNA.dat', 'r');

my $final_fh = FileHandle->new('/lustre/scratch110/ensembl/at7/release_85/human/final_tv', 'w');

my $tv_id;
while (<$fh>) {
  chomp;
  my @data = split/\t/;
  $tv_id = $data[0];
  my $transcript_id = $data[2];
  if (!$transcripts->{$transcript_id}) {
    print $final_fh join("\t", @data), "\n";
  }
}

$fh->close();


$fh = FileHandle->new('/lustre/scratch110/ensembl/at7/release_85/human/new_transcript_variation.dat', 'r');

while (<$fh>) {
  chomp;
  my @data = split/\t/;
  $tv_id++;
  $data[0] = $tv_id;
  print $final_fh join("\t", @data), "\n";
}
$fh->close();


$final_fh->close();

