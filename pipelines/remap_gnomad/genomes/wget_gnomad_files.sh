dir=/hps/nobackup2/production/ensembl/anja/gnomad/Genomes/
for i in {1..22} X Y
do
  bsub -J wget_chr$i -o $dir/wget_chr${i}.out -e $dir/wget_chr${i}.err wget https://storage.googleapis.com/gnomad-public/release/2.1/vcf/genomes/gnomad.genomes.r2.1.sites.chr${i}.vcf.bgz -P $dir
done
