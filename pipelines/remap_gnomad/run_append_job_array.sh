dir=/hps/nobackup2/production/ensembl/anja/release_96/human/remap_gnomad/exomes/unique_mappings/
bsub -J "append_gnomad_e[1-24]%13" \
-o ${dir}/append_gnomad_e.%I.out \
-e ${dir}/append_gnomad_e.%I.err \
perl append_unique_mapping_results.pl
