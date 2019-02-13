i=$1
dir=/hps/nobackup2/production/ensembl/anja/gnomad/Genomes/
bcftools annotate -x INFO/vep $dir/gnomad.genomes.r2.1.sites.chr${i}.vcf.bgz | bgzip > $dir/gnomad.genomes.r2.1.sites.chr${i}.vcf.gz
