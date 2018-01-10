use strict;
use warnings;
use DBI; 
use Text::CSV;
use Bio::EnsEMBL::Registry;
my $csv = Text::CSV->new({ sep_char => ',' });
#"Probe Set ID","Affy SNP ID","dbSNP RS ID","Chromosome","Physical Position","Strand","Flank","Allele A","Allele B","cust_snpid","ChrX pseudo-autosomal region 1","ChrX pseudo-autosomal region 2","Genetic Map"
my $file = '/hps/nobackup/production/ensembl/anja/release_91/pig/Axiom_PigHD_v1_Annotation.r3.csv';

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup/production/ensembl/anja/release_91/pig/remapping_genotype_chip/ensembl.registry.oldasm');
my $vdba = $registry->get_DBAdaptor('pig', 'variation');

my $dbh = $vdba->dbc->db_handle();
my $sth = $dbh->prepare(qq{
  SELECT name, seq_region_id FROM seq_region_89;
}, {mysql_use_result => 1});


my $seq_region_mappings = {};
$sth->execute() or die $sth->errstr;
while (my $row = $sth->fetchrow_arrayref) {
  $seq_region_mappings->{$row->[0]} = $row->[1];
}
$sth->finish;

 
open(my $data, '<', $file) or die "Could not open '$file' $!\n";
while (my $line = <$data>) {
  chomp $line;
  next if ($line =~ /^#|Probe/);
  if ($csv->parse($line)) {
    my @fields = $csv->fields();
    my $allele_a = $fields[7];
    my $allele_b = $fields[8];
    if (! grep($allele_a, qw/A C G T/) || ! grep($allele_b, qw/A C G T/)) {
      print STDERR "$allele_a $allele_b\n";    
    }
    my $rs_id = $fields[2];
    my $seq_region_name = $fields[3];
    my $seq_region_id = $seq_region_mappings->{$seq_region_name};
    if (!$seq_region_id) {
      print STDERR "$seq_region_name\n";
    }
    my $position = $fields[4];
    my $flank = $fields[6];
    my $cust_snpid = $fields[9];
    if ($rs_id !~ /^rs/) {
#      $dbh->do(qq{INSERT INTO variation_feature_axiom_chip_89(seq_region_id, seq_region_start, seq_region_end, seq_region_strand, allele_string, variation_name) VALUES($seq_region_id, $position, $position, 1, '$allele_a/$allele_b', '$cust_snpid')});
    } else {
      $dbh->do(qq{INSERT INTO axiom_chip_synonyms(variation_name, synonym_name) values('$rs_id', '$cust_snpid')});
    }

  } else {
      warn "Line could not be parsed: $line\n";
  }
}

=begin
CREATE TABLE `axiom_chip_synonyms` (
  `variation_name` varchar(255) DEFAULT NULL,
  `synonym_name` varchar(255) DEFAULT NULL,
) ENGINE=MyISAM AUTO_INCREMENT=137297040 DEFAULT CHARSET=latin1;
=end
=cut



