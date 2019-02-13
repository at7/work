i=$1
dir=/hps/nobackup2/production/ensembl/anja/gnomad/Exomes/
bcftools annotate -x INFO/vep $dir/gnomad.exomes.r2.1.sites.chr${i}.vcf.bgz | bgzip > $dir/gnomad.exomes.r2.1.sites.chr${i}_noVEP.vcf.gz
