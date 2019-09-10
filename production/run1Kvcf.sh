bsub -J "assign1K[1-24]%8" -q production-rh74 -M 10000 -R "rusage[mem=10000]" \
-o /hps/nobackup2/production/ensembl/anja/release_98/human/dumps/population_dumps/vcf_output/assign1K_vcf_parallel.%I.out \
-e /hps/nobackup2/production/ensembl/anja/release_98/human/dumps/population_dumps/vcf_output/assign1K_vcf_parallel.%I.err \
perl assign_1000G_frequencies_97_38.pl
