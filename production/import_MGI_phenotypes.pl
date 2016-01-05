use strict;
use warnings;

use FileHandle;
use Getopt::Long;
use Bio::EnsEMBL::Registry;
use Bio::OntologyIO;

my $config = {};

GetOptions(
  $config,
  'config_file=s',
) or die "Error: Failed to parse command line arguments\n";

my $config_fh = FileHandle->new($config->{config_file}, 'r');
while (<$config_fh>) {
  chomp;
  my ($key, $value) = split/=/;
  $config->{$key} = $value;
}

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -DB_VERSION => 83,
);

my $gene_adaptor = $registry->get_adaptor('mouse', 'core', 'gene');
my $variation_adaptor = $registry->get_adaptor('mouse', 'variation', 'variation');
my $pf_adaptor = $registry->get_adaptor('mouse', 'variation', 'phenotypefeature');


my $pfs = $pf_adaptor->fetch_all();

my $impc_gene2phenotype = {};

print STDERR "PhenotypeFeatures: ", scalar @$pfs, "\n"; 

foreach my $pf (@$pfs) {
  if ($pf->type eq 'Gene') {
    my $stable_id = $pf->object_id;
    my $phenotype_description = $pf->phenotype->description;
    $impc_gene2phenotype->{$stable_id}->{$phenotype_description} = 1;
  } 
}

my $obo_file = $config->{'MPheno_OBO.ontology'};
my $parser = Bio::OntologyIO->new( -format => "obo", -file => $obo_file);

my $mpo_terms = {};
while (my $ont = $parser->next_ontology()) {
  my @terms = $ont->get_all_terms;
  foreach my $term (@terms) {
    my $stable_id = $term->identifier;
    my $name = $term->name;
    $mpo_terms->{$stable_id} = $name;
  }
}


parse_MGI_phenoGenoMP();
#parse_MGI_phenotypicAllele();


sub parse_MGI_phenoGenoMP {
  my $fh = FileHandle->new($config->{MGI_PhenoGenoMP}, 'r');
  my $header = {
    'Allelic Composition' => 0,
    'Allele Symbol(s)' => 1,
    'Genetic Background' => 2,
    'Mammalian Phenotype ID' => 3,
    'PubMed ID' => 4,
    'MGI Marker Accession ID' => 5, #comma_delimited
  };

  my $gene2phenotype = {};
  while (<$fh>) {
    chomp;
    next if (/^#/);
    my @values = split/\t/;
    my $mgi_markers = $values[$header->{'MGI Marker Accession ID'}];
    my $phenotype_id = $values[$header->{'Mammalian Phenotype ID'}];
    foreach my $mgi_marker (split(',', $mgi_markers)) {
      my $genes = $gene_adaptor->fetch_all_by_external_name($mgi_marker);
      if ($genes) {
        my @ensembl_ids = map { $_->display_id } @$genes;
        foreach my $ensembl_id (@ensembl_ids) {
          $gene2phenotype->{$ensembl_id}->{$phenotype_id} = 1;
        }
      }
    }
  }

  $fh->close();

  print STDERR 'MGI_PhenoGenoMP counts ', scalar keys %$gene2phenotype, "\n";

}

sub parse_MGI_phenotypicAllele {
  my $fh = FileHandle->new($config->{MGI_PhenotypicAllele}, 'r');

  my $header = {
    'MGI Allele Accession ID' => 0,
    'Allele Symbol' => 1,  
    'Allele Name' => 2,
    'Allele Type' => 3,
    'Allele Attribute' => 4,
    'PubMed ID' => 5,
    'MGI Marker Accession ID' => 6,
    'Marker Symbol' => 7,
    'Marker RefSeq ID' => 8,
    'Marker Ensembl ID' => 9,
    'Mammalian Phenotype IDs' => 10,
    'Synonyms' => 11,
  };


  my $genes = {};
  my $ensembl2mgi = {};
  my $mgi_gene2phenotype = {};

  while (<$fh>) {
    chomp;
    next if (/^#/);
    my @values = split/\t/;
    my $allele_name = $values[$header->{'Allele Name'}];
    my $allele_attrib = $values[$header->{'Allele Attribute'}];
    my $allele_type = $values[$header->{'Allele Type'}];
    my $marker_symbol = $values[$header->{'Marker Symbol'}];
    my $mgi_id = $values[$header->{'MGI Marker Accession ID'}] || 'No mgi accession ID';
    my $ensembl_id = $values[$header->{'Marker Ensembl ID'}] || 'No ensembl ID';
    my $phenotype_ids = $values[$header->{'Mammalian Phenotype IDs'}];
    my $pubmed_id = $values[$header->{'PubMed ID'}];

    if ($marker_symbol && $phenotype_ids) {
      $ensembl2mgi->{$ensembl_id}->{$mgi_id} = 1;
      $genes->{$marker_symbol} = 1;
      my $genes = $gene_adaptor->fetch_all_by_external_name($marker_symbol);
      my @ensembl_ids = map { $_->display_id } @$genes;
      foreach my $ensembl_id (@ensembl_ids) {
        foreach my $phenotype_id (split(',', $phenotype_ids)) {
          $mgi_gene2phenotype->{$ensembl_id}->{$phenotype_id} = 1;
        } 
      } 
    }
  }

  $fh->close();

  print STDERR 'IMPC phenotypes ', scalar keys %$impc_gene2phenotype, "\n";
  print STDERR 'MGI phenotypes ', scalar keys %$mgi_gene2phenotype, "\n";

  my $covered_by_impc = 0;
  foreach my $stable_id (keys %$mgi_gene2phenotype) {
    if ($impc_gene2phenotype->{$stable_id}) {
      my @impc_phenotypes = sort keys %{$impc_gene2phenotype->{$stable_id}};
      my @mgi_phenotypes = sort keys %{$mgi_gene2phenotype->{$stable_id}};
#      print STDERR "$stable_id IMPC: ", join(', ', @impc_phenotypes), ' MGI: ', join(', ', sort map { $mpo_terms->{$_ } } @mgi_phenotypes), "\n";
      $covered_by_impc++;
    }
  }

  print STDERR "covered by IMPC: $covered_by_impc\n";

}
#http://www.informatics.jax.org/marker/phenotypes/MGI:1343161


