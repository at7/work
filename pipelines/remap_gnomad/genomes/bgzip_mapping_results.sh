i=$1
dir=/hps/nobackup2/production/ensembl/anja/gnomad/Genomes/mapping_results/
vcf_file=${dir}/gnomad.genomes.r2.1.sites.grch38.chr${i}_noVEP.vcf.unmap
vcf_file_gz=${dir}/gnomad.genomes.r2.1.sites.grch38.chr${i}_noVEP.vcf.unmap.gz
vcf-sort -t ${dir} < $vcf_file | bgzip > $vcf_file_gz
