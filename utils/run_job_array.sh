bsub -J "parse_vcf[1-24]%13" \
-o parse_parallel.%I.out \
-e parse_parallel.%I.err \
perl parse_vcf_gz.pl
