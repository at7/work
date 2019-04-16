dir=/hps/nobackup2/production/ensembl/anja/gnomad/Genomes/mapping_results/crossmap_mappings/
vcf_file=${dir}/gnomad.genomes.r2.1.sites.grch38.chr18_noVEP.vcf
vcf_file_gz=${dir}/gnomad.genomes.r2.1.sites.grch38.chr18_noVEP.vcf.gz
vcf-sort  -t ${dir} < $vcf_file | bgzip > $vcf_file_gz
