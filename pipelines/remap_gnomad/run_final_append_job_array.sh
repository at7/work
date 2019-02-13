dir=/hps/nobackup2/production/ensembl/anja/gnomad/Exomes/mapping_results/log/
bsub -J "append_gnomad_e[1-24]%13" \
-o ${dir}/append_gnomad_e.%I.out \
-e ${dir}/append_gnomad_e.%I.err \
perl append_to_crossmap_results.pl
