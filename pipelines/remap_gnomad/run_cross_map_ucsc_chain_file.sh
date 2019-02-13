log_dir=/hps/nobackup2/production/ensembl/anja/gnomad/Exomes/crossmap_reports/
for i in 1
do
  bsub -J crossmap_ucsc_chr${i} -o $log_dir/crossmap_ucsc_chr${i}.out -e $log_dir/crossmap_ucsc_chr${i}.err sh cross_map_ucsc_chain_file.sh $i
done
