tmpdir=/hps/nobackup/production/ensembl/anja/release_91/gibbon/
bsub \
-J compress_genotypes \
-o ${tmpdir}compress_genotypes.out \
-e ${tmpdir}compress_genotypes.err \
-R"select[mem>8500] rusage[mem=8500]" -M8500 \
perl compress_genotypes_by_var.pl \
-tmpdir ${tmpdir} \
-species gibbon \
-registry_file ${tmpdir}ensembl.registry \
-tmpfile compress_genotypes.txt \
-table tmp_sample_genotype_single_bp \
