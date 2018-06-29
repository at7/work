use strict;
use warnings;

use FileHandle;

use Bio::EnsEMBL::Registry;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 92,
);

my $slice_adaptor = $registry->get_adaptor('human', 'core', 'slice');

my $slice = $slice_adaptor->fetch_by_region('chromosome', 1);


my $ensembl_translations = {};

for my $gene (@{ $slice->get_all_Genes(undef, undef, 1) }) {
  for my $transcript (@{$gene->get_all_Transcripts}) {
    my $translation = $transcript->translation;
    if ($translation) {
      my $stable_id = $translation->stable_id;
      my $length = $translation->length;
      $ensembl_translations->{$stable_id} = $length;
    }
  }
}

my $fh = FileHandle->new('', 'r');


#translation -> location -> tool -> score

my @headers;
my $dbNSFP_translations = {};
while (<$fh>) {
  chomp;
  if (/^chr/) {
    @headers = split/\t/;
    next;
  }
  my @split = split/\t/;
  # parse data into hash of col names and values
  my %data = map {$headers[$_] => $split[$_]} (0..(scalar @headers - 1));
  my $chr = $data{'chr'};
  my $pos = $data{'pos(1-based)'};
  my $rs_dbSNP150 = $data{'rs_dbSNP150'};
  my $ref = $data{'ref'};
  my $alt = $data{'alt'};
  my $aaalt = $data{'aaalt'};
  my $aaref = $data{'aaref'};
  next if ($data{'aapos'} eq "-1");
  my @aapos = ($data{'aapos'} eq '.') ? () : split(';', $data{'aapos'});
  my @Ensembl_proteinids = ($data{'Ensembl_proteinid'} eq '.') ? () : split(';', $data{'Ensembl_proteinid'});
  my $cadd_raw = $data{'cadd_raw'};
  my $REVEL_score = $data{'REVEL_score'};
  my $FATHMM_score = $data{'FATHMM_score'};
  my $FATHMM_pred = $data{'FATHMM_pred'};
  my $MutationAssessor_score = $data{'MutationAssessor_score'};
  my $MutationAssessor_pred = $data{'MutationAssessor_pred'};
  my $MetaSVM_score = $data{'MetaSVM_score'};
  my $MetaSVM_pred = $data{'MetaSVM_pred'};
  my $MetaLR_score = $data{'MetaLR_score'};
  my $MetaLR_pred = $data{'MetaLR_pred'};
  next unless (scalar @aapos > 0);
  foreach my $i (0 .. $#Ensembl_proteinids) {
    if (scalar @aapos == 1) {
      $pos = $aapos[0];
    } else {
      $pos = $aapos[$i];
    }
    my $protein_id = $Ensembl_proteinids[$i];
    if (!$pos) {
      print STDERR $_, "\n";
      next;
    }
    if ($cadd_raw ne '.') {
      $dbNSFP_translations->{$protein_id}->{CADD}->{$pos} = $cadd_raw;
    }
    if ($REVEL_score ne '.') {
      $dbNSFP_translations->{$protein_id}->{REVEL}->{$pos} = $REVEL_score;
    }
  }
}
$fh->close;

$fh = FileHandle->new('', 'w');

foreach my $protein_id (keys %$dbNSFP_translations) {
  my $ensembl_translation_size = $ensembl_translations->{$protein_id};
  if ($ensembl_translation_size) {
    my $cadd_scores =  scalar keys %{$dbNSFP_translations->{$protein_id}->{CADD}};
    my $revel_scores = scalar keys %{$dbNSFP_translations->{$protein_id}->{REVEL}};
    print $fh "$protein_id $ensembl_translation_size $cadd_scores $revel_scores\n";
  }
}
$fh->close;

