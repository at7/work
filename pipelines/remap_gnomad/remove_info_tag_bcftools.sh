dir=/hps/nobackup2/production/ensembl/anja/gnomad/Exomes/
bcftools annotate -x INFO/vep $dir/gnomad.exomes.r2.1.sites.chr5.vcf.bgz -o $dir/gnomad.exomes.r2.1.sites.chr5.vcf_noVEP.vcf
