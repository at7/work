dir=/hps/nobackup2/production/ensembl/anja/gnomad/Genomes/mapping_results/
for i in 17
do
  bsub -J qc$i -o $dir/qc${i}.out -e $dir/qc${i}.err perl parse_vcf.pl $i
done
