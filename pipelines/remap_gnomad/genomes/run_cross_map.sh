log_dir=/hps/nobackup2/production/ensembl/anja/gnomad/Genomes/crossmap_reports/
for i in {1..22} X Y
do
  bsub -J crossmap_chr${i} -o $log_dir/crossmap_chr${i}.out -e $log_dir/crossmap_chr${i}.err sh cross_map.sh $i
done
