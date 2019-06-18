bsub -J "parse_vcf[11-693]%20" \
-o parse_parallel.%I.out \
-e parse_parallel.%I.err \
perl update_aa.pl
