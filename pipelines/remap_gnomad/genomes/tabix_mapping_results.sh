dir=/hps/nobackup2/production/ensembl/anja/gnomad/Genomes/mapping_results/unmapped/
for i in {1..22} X
do
  bsub -J tabix_chr$i -o $dir/tabix_chr${i}.out -e $dir/tabix_chr${i}.err tabix ${dir}/gnomad.genomes.r2.1.sites.grch38.chr${i}_noVEP.vcf.gz
done
