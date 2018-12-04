working_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
perl  $HOME/bin/ensembl-vep/vep \
--cache \
--registry /hps/nobackup2/production/ensembl/anja/release_95/human/vep_dumps/ensembl.registry \
--assembly GRCh38 \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file $working_dir/input/grch38/LD.txt \
--output_file $working_dir/output/grch38/LD.out \
--force_overwrite \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin LD,1000GENOMES:phase_3:PJL,0.8 \
