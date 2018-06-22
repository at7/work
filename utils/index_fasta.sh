tmpdir=/hps/nobackup2/production/ensembl/anja/release_93/cat/remapping/new_assembly/
bsub \
-J bwa_index \
-o ${tmpdir}bwa_index.out \
-e ${tmpdir}bwa_index.err \
-M4500 -R"select[mem>4500] rusage[mem=4500]" \
bwa index -a bwtsw ${tmpdir}Felis_catus.Felis_catus_9.0.dna.toplevel.fa
