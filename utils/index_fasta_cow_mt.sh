tmpdir=/hps/nobackup2/production/ensembl/anja/release_96/cow/remapping/new_assembly/
bsub \
-J bwa_index \
-o ${tmpdir}bwa_index.out \
-e ${tmpdir}bwa_index.err \
-M4500 -R"select[mem>4500] rusage[mem=4500]" \
bwa index -a bwtsw ${tmpdir}Bos_taurus.ARS-UCD1.2.dna_sm.primary_assembly.MT.fa
