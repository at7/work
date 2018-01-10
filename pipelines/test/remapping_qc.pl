use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use DBI;
use FileHandle;
use Bio::DB::Fasta;
use Bio::EnsEMBL::Utils::Sequence qw(reverse_comp expand);
use Bio::EnsEMBL::Variation::Utils::RemappingUtils qw(qc_mapped_vf);
my $failed_descriptions = {
  1 =>  'Variant maps to more than 3 different locations',
  2 =>  'None of the variant alleles match the reference allele',
  3 =>  'Variant has more than 3 different alleles',
  4 =>  'Loci with no observed variant alleles in dbSNP',
  5 =>  'Variant does not map to the genome',
  6 =>  'Variant has no genotypes',
  7 =>  'Genotype frequencies do not add up to 1',
  8 =>  'Variant has no associated sequence',
  9 =>  'Variant submission has been withdrawn by the 1000 genomes project due to high false positive rate',
  11 => 'Additional submitted allele data from dbSNP does not agree with the dbSNP refSNP alleles',
  12 => 'Variant has more than 3 different submitted alleles',
  13 => 'Alleles contain non-nucleotide characters',
  14 => 'Alleles contain ambiguity codes',
  15 => 'Mapped position is not compatible with reported alleles',
  16 => 'Flagged as suspect by dbSNP',
  17 => 'Variant can not be re-mapped to the current assembly',
  18 => 'Supporting evidence can not be re-mapped to the current assembly',
  19 => 'Variant maps to more than one genomic location',
  20 => 'Variant at first base in sequence',
};

my @copy_over_failure_reasons = (3, 4, 6, 7, 8, 9, 11, 12, 13, 14, 16, 18, 20);

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup/production/ensembl/anja/release_90/pig/remapping/ensembl.registry.newasm');

my $vdba = $registry->get_DBAdaptor('sus_scrofa', 'variation');

#my $vdba = $self->param('vdba_newasm');

my $dbh = $vdba->dbc->db_handle();
#my $mapping_qc_dir = $self->param('mapping_qc_dir');
my $qc_mapped_features_dir = '/hps/nobackup/production/ensembl/anja/release_90/pig/remapping/qc_mapped_features/';

#dump_mapped_features();
qc_mapped_features();

sub dump_mapped_features {
my @output = ();
my $file_count = 1;
#my $entries_per_file = $self->param('entries_per_file');
my $entries_per_file = 200000;
my $count_entries = 0;
my $fh = FileHandle->new("$qc_mapped_features_dir/$file_count.txt", 'w');

my @column_names = qw/variation_feature_id seq_region_id seq_region_name seq_region_start seq_region_end seq_region_strand allele_string variation_id variation_name map_weight alignment_quality/;
my $column_concat = join(',', @column_names);

#my $feature_table = $self->param('feature_table'); #mapping results
my $feature_table = 'variation_feature_mapping_results';

my $sth = $dbh->prepare(qq{
  SELECT vf.variation_feature_id, vf.seq_region_id, sr.name, vf.seq_region_start, vf.seq_region_end, vf.seq_region_strand, vf.allele_string, vf.variation_id, vf.variation_name, vf.map_weight, vf.alignment_quality
  FROM $feature_table vf, seq_region sr
  WHERE sr.seq_region_id = vf.seq_region_id;
}, {mysql_use_result => 1});

$sth->execute();
while (my $row = $sth->fetchrow_arrayref) {
  my @values = map { defined $_ ? $_ : '\N'} @$row;
  my @pairs = ();
  for my $i (0..$#column_names) {
    push @pairs, "$column_names[$i]=$values[$i]";
  }
  if ($count_entries >= $entries_per_file) {
    $fh->close();
    $file_count++;
    $fh = FileHandle->new("$qc_mapped_features_dir/$file_count.txt", 'w');
    $count_entries = 0;
  }
  $count_entries++;
  print $fh join("\t", @pairs), "\n";
}

$sth->finish();
$fh->close();
#$self->param('file_count', $file_count);
}

sub qc_mapped_features {
  my $fasta_db = Bio::DB::Fasta->new('/hps/nobackup/production/ensembl/anja/release_90/pig/remapping/new_assembly/', -reindex => 1);
  my $config = {
    fasta_db => $fasta_db,
    mapped_features_file => '/hps/nobackup/production/ensembl/anja/release_90/pig/remapping/qc_mapped_features/11.txt',
    update_features_file => '/hps/nobackup/production/ensembl/anja/release_90/pig/remapping/qc_update_features/11.txt',
    failure_reasons_file => '/hps/nobackup/production/ensembl/anja/release_90/pig/remapping/qc_failure_reasons/11.txt',
    feature_table => 'variation_feature_mapping_results',
    vdba => $vdba,
  };
  qc_mapped_vf($config);
}

sub read_line {
  my $line = shift;
  my @key_values = split("\t", $line);
  my $mapping = {};
  foreach my $key_value (@key_values) {
    my ($table_name, $value) = split('=', $key_value, 2);
    $mapping->{$table_name} = $value;
  }
  return $mapping;
}





