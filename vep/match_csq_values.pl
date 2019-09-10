use strict;
use warnings;


my $csq_header_line = 'Allele|Consequence|IMPACT|SYMBOL|Gene|Feature_type|Feature|BIOTYPE|EXON|INTRON|HGVSc|HGVSp|cDNA_position|CDS_position|Protein_position|Amino_acids|Codons|Existing_variation|ALLELE_NUM|DISTANCE|STRAND|FLAGS|SYMBOL_SOURCE|HGNC_ID|REFSEQ_MATCH|SOURCE|AF|AFR_AF|AMR_AF|EAS_AF|EUR_AF|SAS_AF|gnomAD_AF|gnomAD_AFR_AF|gnomAD_AMR_AF|gnomAD_ASJ_AF|gnomAD_EAS_AF|gnomAD_FIN_AF|gnomAD_NFE_AF|gnomAD_OTH_AF|gnomAD_SAS_AF|MAX_AF|MAX_AF_POPS|CLIN_SIG|SOMATIC|PHENO|gnomAD|gnomAD_AF|gnomAD_AF_eas|gnomAD_AF_oth|gnomAD_AF_popmax|gnomAD_popmax';

my @header_values = split('\|', $csq_header_line);

my $values = 'C|non_coding_transcript_exon_variant|MODIFIER|LINC00115|79854|Transcript|NR_024321.1|lncRNA|1/1||||314|||||rs3115848|1||-1||EntrezGene||||0.7516|0.4584|0.8156|0.8879|0.8718|0.8384|8.07859e-01&0.8079|0.451|0.7921|0.8398|0.8939|0.8028|0.8562|0.8392|0.8083|0.8939|gnomAD_EAS||||rs3115848|8.07859e-01&0.8079|8.93900e-01|8.39224e-01|8.93900e-01|eas,C|upstream_gene_variant|MODIFIER|LINC01128|643837|Transcript|NR_047519.1|lncRNA||||||||||rs3115848|1|382|1||EntrezGene||||0.7516|0.4584|0.8156|0.8879|0.8718|0.8384|8.07859e-01&0.8079|0.451|0.7921|0.8398|0.8939|0.8028|0.8562|0.8392|0.8083|0.8939|gnomAD_EAS||||rs3115848|8.07859e-01&0.8079|8.93900e-01|8.39224e-01|8.93900e-01|eas,C|upstream_gene_variant|MODIFIER|LINC01128|643837|Transcript|NR_047521.1|lncRNA||||||||||rs3115848|1|382|1||EntrezGene||||0.7516|0.4584|0.8156|0.8879|0.8718|0.8384|8.07859e-01&0.8079|0.451|0.7921|0.8398|0.8939|0.8028|0.8562|0.8392|0.8083|0.8939|gnomAD_EAS||||rs3115848|8.07859e-01&0.8079|8.93900e-01|8.39224e-01|8.93900e-01|eas,C|upstream_gene_variant|MODIFIER|LINC01128|643837|Transcript|NR_047523.1|lncRNA||||||||||rs3115848|1|382|1||EntrezGene||||0.7516|0.4584|0.8156|0.8879|0.8718|0.8384|8.07859e-01&0.8079|0.451|0.7921|0.8398|0.8939|0.8028|0.8562|0.8392|0.8083|0.8939|gnomAD_EAS||||rs3115848|8.07859e-01&0.8079|8.93900e-01|8.39224e-01|8.93900e-01|eas,C|upstream_gene_variant|MODIFIER|LINC01128|643837|Transcript|NR_047524.1|lncRNA||||||||||rs3115848|1|382|1||EntrezGene||||0.7516|0.4584|0.8156|0.8879|0.8718|0.8384|8.07859e-01&0.8079|0.451|0.7921|0.8398|0.8939|0.8028|0.8562|0.8392|0.8083|0.8939|gnomAD_EAS||||rs3115848|8.07859e-01&0.8079|8.93900e-01|8.39224e-01|8.93900e-01|eas,C|upstream_gene_variant|MODIFIER|LINC01128|643837|Transcript|NR_047525.1|lncRNA||||||||||rs3115848|1|589|1||EntrezGene||||0.7516|0.4584|0.8156|0.8879|0.8718|0.8384|8.07859e-01&0.8079|0.451|0.7921|0.8398|0.8939|0.8028|0.8562|0.8392|0.8083|0.8939|gnomAD_EAS||||rs3115848|8.07859e-01&0.8079|8.93900e-01|8.39224e-01|8.93900e-01|eas,C|upstream_gene_variant|MODIFIER|LINC01128|643837|Transcript|NR_047526.1|lncRNA||||||||||rs3115848|1|382|1||EntrezGene||||0.7516|0.4584|0.8156|0.8879|0.8718|0.8384|8.07859e-01&0.8079|0.451|0.7921|0.8398|0.8939|0.8028|0.8562|0.8392|0.8083|0.8939|gnomAD_EAS||||rs3115848|8.07859e-01&0.8079|8.93900e-01|8.39224e-01|8.93900e-01|eas';


foreach my $row (split(',', $values)) {
  my @row_values = split('\|', $row);
  print scalar @row_values, "\n";
  foreach my $i (0..$#row_values) {
    print $header_values[$i], " ", $row_values[$i], "\n";
  }


}
