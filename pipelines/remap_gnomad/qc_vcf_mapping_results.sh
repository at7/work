dir=/hps/nobackup2/production/ensembl/anja/gnomad/Exomes/mapping_results/
for i in {1..22} X Y
do
  bsub -J qc$i -o $dir/qc${i}.out -e $dir/qc${i}.err perl parse_vcf.pl $i
done
