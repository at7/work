i=$1
working_dir=/hps/nobackup2/production/ensembl/anja/gnomad/
CrossMap.py vcf \
$working_dir/GRCh37_to_GRCh38.chain.gz \
$working_dir/Genomes/gnomad.genomes.r2.1.sites.chr${i}_noVEP.vcf.gz \
$working_dir/fasta/Homo_sapiens.GRCh38.dna.primary_assembly.fa \
$working_dir/Genomes/mapping_results/gnomad.genomes.r2.1.sites.grch38.chr${i}_noVEP.vcf
