dir=/hps/nobackup2/production/ensembl/anja/gnomad/Exomes/mapping_results/
for i in 2
do
  bsub -J sort_bgzip$i -o $dir/sort_bgzip${i}.out -e $dir/sort_bgzip${i}.err sh bgzip_mapping_results.sh $i
done
