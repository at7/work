dir=/hps/nobackup2/production/ensembl/anja/gnomad/Exomes/
for i in {1..22} X Y
do
  bsub -J tabix_chr$i -o $dir/tabix_chr${i}.out -e $dir/tabix_chr${i}.err tabix ${dir}/gnomad.exomes.r2.1.sites.chr${i}_noVEP.vcf.gz
done
