working_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
perl  $HOME/bin/ensembl-vep/vep \
--cache \
--offline \
--assembly GRCh37 \
--port 3337 \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file $working_dir/input/grch37/vep.variants.benign.txt \
--output_file $working_dir/output/grch37/vep.variants.benign.out \
--force_overwrite \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin dbNSFP,'consequence=ALL',/nfs/production/panda/ensembl/variation/data/dbNSFP/3.5a_grch37/dbNSFP3.5a_grch37.txt.gz,CADD_phred \
