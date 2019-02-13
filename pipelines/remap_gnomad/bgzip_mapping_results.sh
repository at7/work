i=$1
dir=/hps/nobackup2/production/ensembl/anja/gnomad/Exomes/mapping_results/
vcf_file=${dir}/gnomad.exomes.r2.1.sites.grch38.chr${i}_noVEP.vcf
vcf_file_gz=${dir}/gnomad.exomes.r2.1.sites.grch38.chr${i}_noVEP.vcf.gz
vcf-sort < $vcf_file | bgzip > $vcf_file_gz
