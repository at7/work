dir=/hps/nobackup2/production/ensembl/anja/gnomad/Genomes/mapping_results/log/
bsub -J "append_gnomad_e[12,14,15,16,17]%5" \
-o ${dir}/append_gnomad_g.%I.out \
-e ${dir}/append_gnomad_g.%I.err \
perl append_to_crossmap_results.pl
