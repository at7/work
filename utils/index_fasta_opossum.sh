tmpdir=/hps/nobackup2/production/ensembl/anja/release_98/opossum/remapping/new_assembly/
bsub \
-J bwa_index \
-o ${tmpdir}bwa_index.out \
-e ${tmpdir}bwa_index.err \
-q production-rh7 -M 8000 -R "rusage[mem=8000]" \
bwa index -a bwtsw ${tmpdir}Monodelphis_domestica.ASM229v1.dna_sm.toplevel.fa
