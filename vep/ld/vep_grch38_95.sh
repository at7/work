working_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
perl  $HOME/bin/ensembl-vep/vep \
--cache \
--assembly GRCh38 \
--offline \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file $working_dir/input/grch38/LD.txt \
--output_file $working_dir/output/grch38/LD.out \
--force_overwrite \
