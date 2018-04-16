use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $reg = 'Bio::EnsEMBL::Registry';

$reg->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

$reg = 'Bio::EnsEMBL::Registry';

  $reg->load_registry_from_db(-host => 'ensembldb.ensembl.org',-user => 'anonymous');

  my $sva   = $reg->get_adaptor("human","variation","structuralvariation");
  my $svpf_adaptor = $reg->get_adaptor("human","variation","structuralvariationpopulationfrequency");

  # Get a StructuralVariation by its internal identifier
  my $sv = $sva->fetch_by_dbID(145);

  # Get a StructuralVariation by its name
  $sv = $sva->fetch_by_name('esv3631253');

  # Get the StructuralVariationPopulationFrequency object from the StructuralVariation object
  my $svpfs = $svpf_adaptor->fetch_all_by_StructuralVariation($sv);

  foreach my $svpf (@$svpfs) {
    my $pop_name = $svpf->name;
    my $samples_count = 0;

    # Global frequency
    foreach my $SO_term (keys(%{$svpf->{samples_class}})) {
      $samples_count += scalar(keys %{$svpf->{samples_class}->{$SO_term}});
    }
    print $pop_name.">> Global frequency: ".sprintf("%.4f",$svpf->frequency)." (Samples: $samples_count | Pop size: ".$svpf->size.")\n";

    # Allele class frequency
    my $freqs_by_SO_term = $svpf->frequencies_by_class_SO_term;
    foreach my $SO_term (keys(%$freqs_by_SO_term)) {
      print "> $SO_term: ".sprintf("%.4f",$freqs_by_SO_term->{$SO_term})."\n";
    }
  }

=begin
my $sva = $registry->get_adaptor("human", "variation", "structuralvariation");
my $svpfa = $registry->get_adaptor("human","variation","structuralvariationpopulationfrequency");


my $sv = $sva->fetch_by_name('esv3817090');

my $svpfs = $svpfa->fetch_all_by_StructuralVariation($sv);
foreach my $svpf (@$svpfs) {
  my $pop_name = $svpf->name;
  my $samples_count = 0;
  my $frequency = $svpf->frequency; 
  print $frequency, "\n";

  print keys %{$svpf->{samples_class}}, "\n";

  # Global frequency
  foreach my $SO_term (keys(%{$svpf->{samples_class}})) {
    $samples_count += scalar(keys %{$svpf->{samples_class}->{$SO_term}});
  }
  print $pop_name.">> Global frequency: ".sprintf("%.4f",$svpf->frequency)." (Samples: $samples_count | Pop size: ".$svpf->size.")\n";
  
  # Allele class frequency
#  my $freqs_by_SO_term = $svpf->frequencies_by_class_SO_term;
#  foreach my $SO_term (keys(%$freqs_by_SO_term)) {
#    print "> $SO_term: ".sprintf("%.4f",$freqs_by_SO_term->{$SO_term})."\n";
#  }
}

print $sv, "\n";


=begin
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
=end
=cut










