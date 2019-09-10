use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;
use DBI;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 97,
  -port => 3337,
);

my $dbh = DBI->connect("DBI:mysql:host=mysql-ens-var-prod-1.ebi.ac.uk;database=anja_test_db_homo_sapiens_variation_20190812_145113;port=4449", "ensadmin", "ensembl", {'RaiseError' => 1});

my @variant_names = qw/rs2394878 rs562436031 rs9263526 rs2535284 rs9263509 rs9263525 rs3130548 rs2517556 rs9263529 rs9263513 rs9263537 rs2394877 rs2535282 rs9263566 rs2517558/;
my $va = $registry->get_adaptor('homo_sapiens', 'variation', 'Variation');
my $vfa = $registry->get_adaptor('homo_sapiens', 'variation', 'VariationFeature');

foreach my $name (@variant_names) {
  my $variation = $va->fetch_by_name($name);
  my ($vf) = grep {$_->slice->is_reference} @{$vfa->fetch_all_by_Variation($variation)};
  my $allele_string = $vf->allele_string;
  my $chr = $vf->seq_region_name;
  my $start = $vf->seq_region_start;
  my $end = $vf->seq_region_end;
  my $seq_region_id = $vf->slice->get_seq_region_id;
  my $rsid = $name;
  my $source_id = 1;
  my $class_attrib_id = 2;

  my $sth = $dbh->prepare(q{ SELECT variation_id FROM variation where name = ?;}, {mysql_use_result => 1});
  $sth->execute($rsid) or die $dbh->errstr;
  my ($variation_id);
  $sth->bind_columns(\($variation_id));
  $sth->fetch;
  $sth->finish();


  $dbh->do(qq{INSERT INTO variation_feature(seq_region_id, seq_region_start, seq_region_end, seq_region_strand, variation_id, allele_string, variation_name, map_weight, source_id, class_attrib_id) VALUES( $seq_region_id, $start, $end, 1, $variation_id, '$allele_string', '$rsid', 1,  $source_id, $class_attrib_id)});


  
#  $dbh->do(qq{INSERT INTO variation(name, source_id, class_attrib_id) VALUES('$rsid', $source_id, $class_attrib_id)});
}

=begin
my $already_in_db = {};
my $dbh = DBI->connect("DBI:mysql:host=localhost;database=anjathormann_test_db_homo_sapiens_variation_20160408_115134", "", "", {'RaiseError' => 1});
my $sth = $dbh->prepare(q{ SELECT variation_name FROM variation_feature;}, {mysql_use_result => 1});
$sth->execute() or die $dbh->errstr;
my ($name);
$sth->bind_columns(\($name));
while ($sth->fetch) {
  $already_in_db->{$name} = 1;
}
$sth->finish();

my $variation_adaptor = $registry->get_adaptor('homo_sapiens', 'variation', 'variation');

my $rsids = {};

my $fh = FileHandle->new("$ENV{HOME}/test.vcf", 'r');
while (<$fh>) {
  chomp;
  next if /^#/;
  my @values = split/\t/;
  my $rsid = $values[2];
  next if ($already_in_db->{$rsid}); 
  my $variation = $variation_adaptor->fetch_by_name($rsid);
  $rsids->{$rsid} = $variation;
}

$fh->close();

print scalar keys %$rsids, "\n";

my $edbh = $variation_adaptor->dbc;

my (
$seq_region_id, $seq_region_start, $seq_region_end, $seq_region_strand, $allele_string, $map_weight, $flags, $source_id, $consequence_types, $variation_set_id, $class_attrib_id, $somatic, $minor_allele, $minor_allele_freq, $minor_allele_count, $alignment_quality, $clinical_significance, $evidence_attribs, $display
);

$sth = $edbh->prepare(q{ SELECT seq_region_id, seq_region_start, seq_region_end, seq_region_strand, allele_string, map_weight, flags, source_id, consequence_types, variation_set_id, class_attrib_id, somatic, minor_allele, minor_allele_freq, minor_allele_count, alignment_quality, clinical_significance, evidence_attribs, display FROM variation_feature WHERE variation_id=?;
}, {mysql_use_result => 1});

foreach my $rsid (keys %$rsids) {
  my $variation_id = $rsids->{$rsid}->dbID;
  $sth->execute($variation_id) or die $edbh->errstr;
  $sth->bind_columns(\( $seq_region_id, $seq_region_start, $seq_region_end, $seq_region_strand, $allele_string, $map_weight, $flags, $source_id, $consequence_types, $variation_set_id, $class_attrib_id, $somatic, $minor_allele, $minor_allele_freq, $minor_allele_count, $alignment_quality, $clinical_significance, $evidence_attribs, $display));
  while ($sth->fetch) {
    $minor_allele = defined $minor_allele ? "'$minor_allele'" : '\N';
    $clinical_significance = defined $clinical_significance ? "'$clinical_significance'" : '\N';
    $evidence_attribs = defined $evidence_attribs ? "'$evidence_attribs'" : '\N';

    ($seq_region_id, $seq_region_start, $seq_region_end, $seq_region_strand, $allele_string, $map_weight, $flags, $source_id, $consequence_types, $variation_set_id, $class_attrib_id, $somatic, $minor_allele, $minor_allele_freq, $minor_allele_count, $alignment_quality, $clinical_significance, $evidence_attribs, $display) =  map { defined $_ ? $_ : '\N' } ( $seq_region_id, $seq_region_start, $seq_region_end, $seq_region_strand, $allele_string, $map_weight, $flags, $source_id, $consequence_types, $variation_set_id, $class_attrib_id, $somatic, $minor_allele, $minor_allele_freq, $minor_allele_count, $alignment_quality, $clinical_significance, $evidence_attribs, $display);
  print join(', ', $seq_region_id, $seq_region_start, $seq_region_end, $seq_region_strand, $allele_string, $map_weight, $flags, $source_id, $consequence_types, $variation_set_id, $class_attrib_id, $somatic, $minor_allele, $minor_allele_freq, $minor_allele_count, $alignment_quality, $clinical_significance, $evidence_attribs, $display), "\n";
    $dbh->do(qq{INSERT INTO variation_feature(variation_name, seq_region_id, seq_region_start, seq_region_end, seq_region_strand, allele_string, map_weight, flags, source_id, consequence_types, variation_set_id, class_attrib_id, somatic, minor_allele, minor_allele_freq, minor_allele_count, alignment_quality, clinical_significance, evidence_attribs, display) VALUES('$rsid', $seq_region_id, $seq_region_start, $seq_region_end, $seq_region_strand, '$allele_string', $map_weight, $flags, $source_id, '$consequence_types', '$variation_set_id', $class_attrib_id, $somatic, $minor_allele, $minor_allele_freq, $minor_allele_count, $alignment_quality, $clinical_significance, $evidence_attribs, $display)});

  }
  $sth->finish();
}



sub import_variations { 
  my $already_in_db = {};
  my $dbh = DBI->connect("DBI:mysql:host=localhost;database=anjathormann_test_db_homo_sapiens_variation_20160408_115134", "root", "root", {'RaiseError' => 1});
  my $sth = $dbh->prepare(q{ SELECT name FROM variation;}, {mysql_use_result => 1});
  $sth->execute() or die $dbh->errstr;
  my ($name);
  $sth->bind_columns(\($name));
  while ($sth->fetch) {
    $already_in_db->{$name} = 1;
  }
  $sth->finish();

  my $variation_adaptor = $registry->get_adaptor('homo_sapiens', 'variation', 'variation');

  my $rsids = {};

  my $fh = FileHandle->new("$ENV{HOME}/test.vcf", 'r');
  while (<$fh>) {
    chomp;
    next if /^#/;
    my @values = split/\t/;
    my $rsid = $values[2];
    next if ($already_in_db->{$rsid}); 
    my $variation = $variation_adaptor->fetch_by_name($rsid);
    $rsids->{$rsid} = $variation;
  }

  $fh->close();

  my $edbh = $variation_adaptor->dbc;


  $sth = $edbh->prepare(q{ SELECT source_id, ancestral_allele, flipped, class_attrib_id, somatic, minor_allele, minor_allele_freq, minor_allele_count, clinical_significance, evidence_attribs, display FROM variation WHERE name=?;}, {mysql_use_result => 1});

  foreach my $rsid (keys %$rsids) {
    $sth->execute($rsid) or die $edbh->errstr;
    my ($source_id, $ancestral_allele, $flipped, $class_attrib_id, $somatic, $minor_allele, $minor_allele_freq, $minor_allele_count, $clinical_significance, $evidence_attribs, $display);
    $sth->bind_columns(\($source_id, $ancestral_allele, $flipped, $class_attrib_id, $somatic, $minor_allele, $minor_allele_freq, $minor_allele_count, $clinical_significance, $evidence_attribs, $display));
    while ($sth->fetch) {
      $ancestral_allele = defined $ancestral_allele ? "'$ancestral_allele'" : '\N';
      $minor_allele = defined $minor_allele ? "'$minor_allele'" : '\N';
      $clinical_significance = defined $clinical_significance ? "'$clinical_significance'" : '\N';
      $evidence_attribs = defined $evidence_attribs ? "'$evidence_attribs'" : '\N';

      ($source_id, $ancestral_allele, $flipped, $class_attrib_id, $somatic, $minor_allele, $minor_allele_freq, $minor_allele_count, $clinical_significance, $evidence_attribs, $display) =  map { defined $_ ? $_ : '\N' } ($source_id, $ancestral_allele, $flipped, $class_attrib_id, $somatic, $minor_allele, $minor_allele_freq, $minor_allele_count, $clinical_significance, $evidence_attribs, $display);

      $dbh->do(qq{INSERT INTO variation(name, source_id, ancestral_allele, flipped, class_attrib_id, somatic, minor_allele, minor_allele_freq, minor_allele_count, clinical_significance, evidence_attribs, display) VALUES('$rsid', $source_id, $ancestral_allele, $flipped, $class_attrib_id, $somatic, $minor_allele, $minor_allele_freq, $minor_allele_count, $clinical_significance, $evidence_attribs, $display)});

    }
    $sth->finish();
  }
}
=end
=cut
