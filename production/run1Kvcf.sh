bsub -J "assign1K[1]%8" -q production-rh74 -M 10000 -R "rusage[mem=10000]" \
-o assign1K_vcf_parallel.%I.out \
-e assign1K_vcf_parallel.%I.err \
perl assign_1000G_frequencies_97_38.pl
