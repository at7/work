bsub -J "cleanup[1-24]%8" -q production-rh7 -M 2000 -R "rusage[mem=2000]" \
-o cleanup.%I.out \
-e cleanup.%I.err \
perl clean_up_GVF_93.pl
