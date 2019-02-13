dir=/hps/nobackup2/production/ensembl/anja/gnomad/Genomes/
bcftools annotate -x INFO/vep $dir/gnomad.genomes.r2.1.sites.chr1.vcf.bgz | bgzip > $dir/gnomad.genomes.r2.1.sites.chr1.vcf_noVep.bgz
