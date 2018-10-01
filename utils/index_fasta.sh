tmpdir=/hps/nobackup2/production/ensembl/anja/release_94/chicken/remapping/new_assembly/
bsub \
-J bwa_index \
-o ${tmpdir}bwa_index.out \
-e ${tmpdir}bwa_index.err \
-M4500 -R"select[mem>4500] rusage[mem=4500]" \
bwa index -a bwtsw ${tmpdir}Gallus_gallus.Gallus_gallus-5.0.dna_sm.toplevel.fa
