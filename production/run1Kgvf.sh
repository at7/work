dir=/hps/nobackup2/production/ensembl/anja/release_98/human/dumps/population_dumps/gvf_output/
bsub -J "assign1K[1-24]%8" -q production-rh74 -M 10000 -R "rusage[mem=10000]" \
-o $dir/assign1K_gvf_parallel.%I.out \
-e $dir/assign1K_gvf_parallel.%I.err \
perl assign_1000G_frequencies_GVF_97_38.pl
