dir=/hps/nobackup2/production/ensembl/anja/gnomad/Genomes/mapping_results/
for i in {1..22} X Y
do
  bsub -J sort_bgzip$i -o $dir/sort_bgzip${i}.out -e $dir/sort_bgzip${i}.err sh bgzip_mapping_results.sh $i
done
