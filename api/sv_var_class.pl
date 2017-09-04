use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

#$registry->load_registry_from_db(
#  -host => 'ensembldb.ensembl.org',
#  -user => 'anonymous',
#  -db_version => 89,
#);

$registry->load_all('/hps/nobackup/production/ensembl/anja/release_90/dumps_dog/ensembl.registry');

my $ontology = $registry->get_adaptor('Multi', 'Ontology', 'OntologyTerm' );
my $ontology_name = 'SO';

my $vdba = $registry->get_DBAdaptor('dog', 'variation');
my $dbh = $vdba->dbc->db_handle;

my $attribs = {};
my $sth = $dbh->prepare(qq/select distinct a.value from attrib a, structural_variation_feature svf where svf.class_attrib_id = a.attrib_id;/);
$sth->execute() or die $sth->errstr;
while (my $row = $sth->fetchrow_arrayref) {
  my $attrib = $row->[0];
  $attribs->{$attrib} = 1;
}
$sth->finish;

my $var_class_names =  {
    'copy_number_loss' => 'CNV:LOSS',
    'deletion' => 'DEL',
    'sequence_alteration' => 'SA',
    'complex_structural_alteration' => 'CSA',
    'copy_number_gain' => 'CNV:GAIN',
    'duplication' => 'DUP',
    'tandem_duplication' => 'DUP:Tandem',
    'copy_number_variation' => 'CNV',
    'inversion' => 'INV',
    'insertion' => 'INS',
    'mobile_element_insertion' => 'MEI',
    'novel_sequence_insertion' => 'NSI',
    'indel' => 'INDEL',
    'translocation' => 'TL',
    'interchromosomal_breakpoint' => 'InterCB',
    'intrachromosomal_breakpoint' => 'IntraCB',
    'interchromosomal_translocation' => 'InterTL',
    'intrachromosomal_translocation' => 'IntraTL',
    'complex_substitution' => 'CS',
    'Alu_insertion' => 'ALU_INS',
    'short_tandem_repeat_variation' => 'short_tandem_repeat_variation',
    'loss_of_heterozygosity' => 'loss_of_heterozygosity',
    'substitution' => 'substitution',
    'genetic_marker' => 'genetic_marker',
    'mobile_element_deletion' => 'mobile_element_deletion',
};
foreach my $class_name (keys %$attribs) {
  my $terms = $ontology->fetch_all_by_name($class_name);
  print STDERR $class_name, "\n";
  foreach my $term (@$terms) {
    print STDERR $term, "\n";
    if ($term->ontology eq 'SO') {
      $term->definition =~ m/^"(.*)\."\s\[.*\]$/;
      print STDERR $1, "\n";
    }
#    print STDERR '  ', $term->name, ' ', $term->definition, ' ', $term->ontology, "\n";
  }
}











