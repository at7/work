working_dir=/hps/nobackup/production/ensembl/anja/
bsub -J vep -o $working_dir/vep_data/1_3_2018.out -e $working_dir/vep_data/1_3_2018.err \
perl $HOME/bin/ensembl-vep/vep \
-i $working_dir/vep_data/input/input_1_3_2018.txt  \
-o $working_dir/vep_data/output/output_1_3_2018_old.txt \
--assembly GRCh37 \
--offline \
--cache \
--fasta $working_dir/vep/Homo_sapiens.GRCh37.dna.primary_assembly.fa.gz \
--dir_cache /hps/nobackup/production/ensembl/anja/vep/ \
--dir_plugins /homes/anja/bin/VEP_plugins/ \
--plugin Downstream  \
--force_overwrite \
