use strict;
use warnings;
use FileHandle;



my $dir = '/hps/nobackup2/production/ensembl/anja/G2P/test_data/'; 

# chr start end strand gene_symbol gene_name
sub format_ddg2p_list {
  my $fh = FileHandle->new("$dir/ddg2p_genes_mappings_23_04_2019.txt", 'r');
  my $out = FileHandle->new("$dir/suspect_gene_list", 'w');
  while (<$fh>) {
    chomp;
    next if (/^Gene/);
    #Gene stable ID  Chromosome/scaffold name  Gene start (bp) Gene end (bp) Strand  Gene name
    my ($stable_id, $chr, $start, $end, $strand, $gene_name) = split;
    next if (! grep {"$_" eq $chr} (1..22) );
    print $out "$chr $start $end $strand $stable_id $gene_name\n";
  }

  $fh->close;
  $out->close;
}

format_all_genes_list();
sub format_all_genes_list {
  my $g2p_genes = {};
  my $fh = FileHandle->new("$dir/sorted_suspect_gene_list", 'r'); 
  while (<$fh>) {
    chomp;
    my @values = split;
    my $gene_symbol = $values[4];
    $g2p_genes->{$gene_symbol} = 1;
  }
  $fh->close;

  $fh = FileHandle->new("$dir/genes_grch37", 'r');
  my $out = FileHandle->new("$dir/gene_list_minus_g2p", 'w');
  while (<$fh>) {
    chomp;
    #ENSG00000159346 1 202909951 202927700 -1
    my ($gene_symbol, $chr, $start, $end, $strand) = split;
    next if ($g2p_genes->{$gene_symbol});
    print $out "$chr $start $end $strand $gene_symbol\n";
  }
  $fh->close;
  $out->close;
}

