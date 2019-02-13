dir=/hps/nobackup2/production/ensembl/anja/gnomad/Exomes/
for i in 17
do
  bsub -J wget_chr$i -o $dir/wget_chr${i}.out -e $dir/wget_chr${i}.err wget https://storage.googleapis.com/gnomad-public/release/2.1/vcf/exomes/gnomad.exomes.r2.1.sites.chr${i}.vcf.bgz -P $dir 
done
