use strict;
use warnings;
use FileHandle;
use Bio::EnsEMBL::Registry;

my $reg = 'Bio::EnsEMBL::Registry';
$reg->load_all('/hps/nobackup/production/ensembl/anja/release_90/human/ESP/ensembl.registry');

my $va   = $reg->get_adaptor('human', 'variation', 'Variation');


my $dbh = $va->dbc->db_handle;

my $sth = $dbh->prepare(qq{SELECT allele_code_id, allele FROM allele_code});
$sth->execute;

my ($code, $allele);
$sth->bind_columns(\$code, \$allele);
my %allele_codes;
$allele_codes{defined($allele) ? $allele : ''} = $code while $sth->fetch;
$sth->finish();


my $in = '/hps/nobackup/production/ensembl/anja/release_90/human/ESP/allele_ESP';
my $out = '/hps/nobackup/production/ensembl/anja/release_90/human/ESP/insert_allele_ESP';
my $fh_in = FileHandle->new($in, 'r');
my $fh_out = FileHandle->new($out, 'w');


my $allele_codes = {};
my $population_ids = {
  'ESP6500:African_American' => 373539,
  'ESP6500:European_American' => 373540,  
};

while(<$fh_in>) {
  chomp;
  my ($id, $population_name, $variant_name, $variant_id, $allele, $count, $frequency) = split/\s+/;
  my $population_id = $population_ids->{$population_name};
  my $allele_code = $allele_codes{$allele};
  if (!($population_id && $allele_code)) {
    print STDERR "$_\n";
  } else {
    print $fh_out "insert into allele(variation_id, allele_code_id, population_id, frequency, count) values($variant_id, $allele_code, $population_id, $frequency, $count);\n"
  }
}

$fh_in->close;
$fh_out->close;
