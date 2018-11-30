use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;


my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_95/human/variation_consequence_38/ensembl.registry');
my $dbh = $registry->get_DBAdaptor('human', 'variation')->dbc->db_handle;

my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/human/variation_consequence_38/failed_transcript_ids2', 'r');

while (<$fh>) {
  chomp;
  $dbh->do(qq{Insert into failed_transcript_ids values('$_'); });
}
$fh->close;

=begin
my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_95/human/variation_consequence_38/ensembl.registry');
my $dbh = $registry->get_DBAdaptor('human', 'variation')->dbc->db_handle;

#1 get transcript_ids
my $ga = $registry->get_adaptor('human', 'core', 'gene');
my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/human/variation_consequence_38/failed_gene_ids2', 'r');
my $fh_out = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/human/variation_consequence_38/failed_transcript_ids2', 'w');
while (<$fh>) {
  chomp;

  my $gene = $ga->fetch_by_stable_id($_);
  my $transcripts = $gene->get_all_Transcripts;
  foreach my $transcript (@$transcripts) {
    print $fh_out $transcript->stable_id, "\n";
  }
}
$fh->close;
=begin
#CREATE TABLE `failed_transcript_ids` (
#  `transcript_id` varchar(128) NOT NULL,
#  PRIMARY KEY (`transcript_id`)
#) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#2 load transcript ids

my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_95/human/variation_consequence_38/failed_transcript_ids', 'r');

while (<$fh>) {
  chomp;
  $dbh->do(qq{Insert into failed_transcript_ids values('$_'); });
}
$fh->close;


#3 delete from TV table
Delete tv from transcript_variation tv
left join failed_transcript_ids f on f.transcript_id = tv.feature_stable_id
where f.transcript_id is not null;


=begin
NOTES
DELETE transcript_variation 
FROM transcript_variation
        LEFT JOIN
    failed_transcript_ids ON transcript_variation.feature_stable_id = .feature_stable_id
WHERE
    orderNumber IS NULL;
DELETE e FROM emailNotification e 
LEFT JOIN jobs j ON j.jobId = e.jobId 
WHERE j.active = 1 AND CURDATE() < j.closeDate
----------------------------------
=end
