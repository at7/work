dir=/hps/nobackup2/production/ensembl/anja/gnomad/Exomes/mapping_results/
for i in 1 {3..22} X Y
do
  bsub -J gunzip_chr$i -o $dir/gunzip_unmap${i}.out -e $dir/gunzip_unmap${i}.err gunzip ${dir}/gnomad.exomes.r2.1.sites.grch38.chr${i}_noVEP.vcf.gz
done
