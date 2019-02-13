dir=/hps/nobackup2/production/ensembl/anja/gnomad/Genomes/
for i in {1..22} X Y
do
  mv $dir/gnomad.genomes.r2.1.sites.chr${i}.vcf.gz $dir/gnomad.genomes.r2.1.sites.chr${i}_noVEP.vcf.gz
done
