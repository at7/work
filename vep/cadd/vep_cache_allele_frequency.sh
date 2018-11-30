working_dir=/hps/nobackup2/production/ensembl/anja/vep_data/cadd_plugin/
perl  $HOME/bin/ensembl-vep/vep \
--cache \
--offline \
--assembly GRCh37 \
--port 3337 \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file $working_dir/input \
--output_file $working_dir/output \
--force_overwrite \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin CADD,'/nfs/production/panda/ensembl/variation/data/CADD/v1.3/CADD_InDels.tsv.gz','/nfs/production/panda/ensembl/variation/data/CADD/v1.3/CADD.tsv.gz' \
