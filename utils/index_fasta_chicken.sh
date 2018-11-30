tmpdir=/hps/nobackup2/production/ensembl/anja/release_95/chicken/remapping/new_assembly_dir/
bsub \
-J bwa_index \
-o ${tmpdir}bwa_index.out \
-e ${tmpdir}bwa_index.err \
-M4500 -R"select[mem>4500] rusage[mem=4500]" \
bwa index -a bwtsw ${tmpdir}gallus_gallus_softmasked_toplevel.fa
