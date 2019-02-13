dir=/hps/nobackup2/production/ensembl/anja/gnomad/Genomes/
for i in {1..22} X Y
do
  bsub -J trim_chr${i} -o $dir/trim_reports/trim_chr${i}.out -e $dir/trim_reports/trim_chr${i}.err sh trim_gnomad_files.sh $i
done
