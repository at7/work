dir=/hps/nobackup2/production/ensembl/anja/gnomad/Exomes/
bcftools annotate -x INFO/vep $dir/gnomad.exomes.r2.1.sites.chr1.vcf.bgz | bgzip > $dir/gnomad.exomes.r2.1.sites.chr1_noVep.bgz
