tmpdir=/hps/nobackup/production/ensembl/anja/release_92/goat/remapping/new_assembly/
bsub \
-J bwa_index \
-o ${tmpdir}bwa_index.out \
-e ${tmpdir}bwa_index.err \
-M4500 -R"select[mem>4500] rusage[mem=4500]" \
/homes/anja/bin/bwa/bwa index -a bwtsw ${tmpdir}capra_hircus_softmasked_toplevel.fa
