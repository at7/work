working_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
perl  $HOME/bin/ensembl-vep/vep \
--cache \
--offline \
--assembly GRCh37 \
--port 3337 \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file $working_dir/input/grch37/homo_sapiens-chr17.vcf.gz \
--output_file $working_dir/output/grch37/chr17.out \
--force_overwrite \
