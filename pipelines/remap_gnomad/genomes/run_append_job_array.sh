dir=/hps/nobackup2/production/ensembl/anja/release_96/human/remap_gnomad/genomes/unique_mappings/
bsub -J "append_gnomad_g[6,9,10,11,15,17,21]%13" \
-o ${dir}/append_gnomad_g.%I.out \
-e ${dir}/append_gnomad_g.%I.err \
perl append_unique_mapping_results.pl
