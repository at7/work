i=$1
working_dir=/hps/nobackup2/production/ensembl/anja/gnomad/
CrossMap.py vcf \
$working_dir/hg19ToHg38.over.chain \
$working_dir/Exomes/gnomad.exomes.r2.1.sites.chr17.vcf.gz \
$working_dir/fasta/Homo_sapiens.GRCh38.dna.primary_assembly.fa \
$working_dir/Exomes/mapping_results_ucsc_chain_files/gnomad.exomes.r2.1.sites.grch38.chr17.vcf
