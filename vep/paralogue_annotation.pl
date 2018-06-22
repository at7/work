use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

my $genome_db_adaptor = $registry->get_adaptor('Multi', 'compara', 'GenomeDB');
my $hg_adaptor = $registry->get_adaptor("Human","Core","Gene");
my $slice_adaptor = $registry->get_adaptor("Human", "Core", "Slice");
my $transcript_adaptor = $registry->get_adaptor("Human", "Core", "Transcript");
my $variationfeature_adaptor = $registry->get_adaptor("Human", "Variation", "Variationfeature");
my $transcriptvariation_adaptor = $registry->get_adaptor("Human", "Variation", "TranscriptVariation");
my $genemember_adaptor = $registry->get_adaptor("Multi", "compara", "GeneMember");
my $homology_adaptor = $registry->get_adaptor('Multi', 'compara', 'Homology');


my $base_Gid = 'ENSG00000078808';
my $basegene = 'SDF4';
#Define variables
my $para_gene = ();
my $REFid = ();
my $col = ();
my $bp_input = 1223269;
my %REFresatlocation = ();
my %ALTresatlocation = ();   
my $gene_member = $genemember_adaptor->fetch_by_stable_id($base_Gid);
my $homologies = $homology_adaptor->fetch_all_by_Member($gene_member, 'ENSEMBL_PARALOGUES');
foreach my $homology (@{$homologies}) {
  my @members = (@{$homology->get_all_Members});
  foreach my $member (@members) {
    print STDERR $member->taxon_id, "\n";
  }
  my %ENSPid = ();
  my %ENSTid = ();
  my %genename = ();
  my %geneobj = ();
  my %transslice = ();
  my %strand = ();
  my %fullseq = ();
  my %trmapper = ();
  my %peptide_coord = ();
  my %peptide = ();
  my %peptide_start = ();
  my %trans = ();
  my $para_gene = '';

  foreach my $member (@members) {
    my $ENSP = $member->stable_id; #confirm using longest trans for all
    my $gene = $hg_adaptor->fetch_by_translation_stable_id($ENSP);
    if ($gene->external_name eq $basegene){
      if (!$ENSPid{$ENSP}) {
        $ENSPid{$basegene}=$member->stable_id;
        $geneobj{$basegene}=$hg_adaptor->fetch_by_translation_stable_id($ENSP);
        $genename{$basegene}=$gene->external_name;
        $trans{$basegene}=$member->get_Transcript;
        $strand{$basegene}=$trans{$basegene}->strand;
        $ENSTid{$basegene} = $trans{$basegene}->display_id;
        $trmapper{$basegene} = Bio::EnsEMBL::TranscriptMapper->new($trans{$basegene});
      }
    } else {
      $para_gene=$gene->external_name;
      $ENSPid{$para_gene}=$member->stable_id;
      $geneobj{$para_gene}=$hg_adaptor->fetch_by_translation_stable_id($ENSP);
      $genename{$para_gene}=$gene->external_name;
      $trans{$para_gene}=$member->get_Transcript;
      $ENSTid{$para_gene} = $trans{$para_gene}->display_id;
      $trmapper{$para_gene} = Bio::EnsEMBL::TranscriptMapper->new($trans{$para_gene});
    }
  }

  my $simplealign = $homology->get_SimpleAlign();
#  my $alignIO = Bio::AlignIO->newFh(
#    -interleaved => 0,
#    -fh => \*STDERR,
#    -format => "clustalw",
#    -idlength => 20);
#  print $alignIO $simplealign;
  $fullseq{$basegene} = $simplealign->get_seq_by_id($ENSPid{$basegene});
  $fullseq{$para_gene} = $simplealign->get_seq_by_id($ENSPid{$para_gene});
  my ($coord) = $trmapper{$basegene}->genomic2pep($bp_input, $bp_input, $strand{$basegene}); #when list has one element how to extract?
  $peptide{$basegene} = $coord->start;
  print STDERR 'base gene peptide location ', $peptide{$basegene}, "\n";
  my $num_residues = $simplealign->num_residues;
  print STDERR 'num_residues ', $num_residues, "\n";
  $col = $simplealign->column_from_residue_number($ENSPid{$basegene}, $peptide{$basegene});
  $peptide_coord{$para_gene} = $fullseq{$para_gene}->location_from_column($col);
  $peptide{$para_gene} = $peptide_coord{$para_gene}->start;
  print STDERR 'para_gene peptide location ', $peptide{$para_gene}, "\n";

  my %codoncoords;
  my @pos2bp_coords = $trmapper{$para_gene}->pep2genomic($peptide{$para_gene}, $peptide{$para_gene});
  foreach my $var (@pos2bp_coords){ #extract one element
    $codoncoords{$para_gene} = $var;
  }

  my $codon_start = $codoncoords{$para_gene}->start;
  my $codon_end = $codoncoords{$para_gene}->end;
  print STDERR "$codon_start $codon_end\n";
  $transslice{$para_gene} = $slice_adaptor->fetch_by_transcript_stable_id($ENSTid{$para_gene});

  my $coord_sys2  = $transslice{$para_gene}->coord_system()->name();
  my $slice2_chr = $transslice{$para_gene}->seq_region_name();
  my $codon_slice2 = $slice_adaptor->fetch_by_region('chromosome', $slice2_chr, $codon_start, $codon_end);

  $REFresatlocation{$basegene} = $fullseq{$basegene}->subseq($col, $col);
  $REFresatlocation{$para_gene} = $fullseq{$para_gene}->subseq($col, $col);

}











