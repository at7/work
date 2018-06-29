use strict;
use warnings;

use Bio::DB::HTS::Tabix;
use FileHandle;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 92,
);

my $file = '';
my $output_file = '';

my $fh = FileHandle->new($output_file, 'w');

my $slice_adaptor = $registry->get_adaptor('human', 'core', 'slice');
my $slice = $slice_adaptor->fetch_by_region('chromosome', 1);

my $chr = 1;
my $start = $slice->start; 
my $end = $slice->end;

my $headers;
open HEAD, "tabix -fh $file 1:1-1 2>&1 | ";
while(<HEAD>) {
  next unless /^\#/;
  chomp;
  $headers = [split];
}
close HEAD;

print join("\n", @$headers), "\n";
die

my $obj = Bio::DB::HTS::Tabix->new(filename => $file);
my $iter = $obj->query("$chr:$start-$end");

my @header_columns = qw/chr pos(1-based) rs_dbSNP150 ref alt aaalt aaref aapos Ensembl_proteinid cadd_raw REVEL_score FATHMM_score FATHMM_pred MutationAssessor_score MutationAssessor_pred MetaSVM_score MetaSVM_pred MetaLR_score MetaLR_pred/;

print $fh join("\t", @header_columns), "\n";

while (my $line = $iter->next) {
 $line =~ s/\r$//g;
  my @split = split /\t/, $line;
  # parse data into hash of col names and values
  my %data = map {$headers->[$_] => $split[$_]} (0..(scalar @{$headers} - 1));
  my $chr = $data{'#chr'};
  my $pos = $data{'pos(1-based)'};
  my $rs_dbSNP150 = $data{'rs_dbSNP150'};
  my $ref = $data{'ref'};
  my $alt = $data{'alt'};
  my $aaalt = $data{'aaalt'};
  my $aaref = $data{'aaref'};
  my $aapos = $data{'aapos'} || 'No aapos';
  my $Ensembl_proteinid = $data{'Ensembl_proteinid'};
  my $cadd_raw = $data{'CADD_raw'}; 
  my $REVEL_score = $data{'REVEL_score'};
  my $FATHMM_score = $data{'FATHMM_score'};
  my $FATHMM_pred = $data{'FATHMM_pred'};
  my $MutationAssessor_score = $data{'MutationAssessor_score'};
  my $MutationAssessor_pred = $data{'MutationAssessor_pred'};
  my $MetaSVM_score = $data{'MetaSVM_score'};
  my $MetaSVM_pred = $data{'MetaSVM_pred'};
  my $MetaLR_score = $data{'MetaLR_score'};
  my $MetaLR_pred = $data{'MetaLR_pred'};

  print $fh join("\t", $chr, $pos, $rs_dbSNP150, $ref, $alt, $aaalt, $aaref, $aapos, $Ensembl_proteinid, $cadd_raw, $REVEL_score, $FATHMM_score, $FATHMM_pred, $MutationAssessor_score, $MutationAssessor_pred, $MetaSVM_score, $MetaSVM_pred, $MetaLR_score, $MetaLR_pred), "\n";
}

$fh->close;

