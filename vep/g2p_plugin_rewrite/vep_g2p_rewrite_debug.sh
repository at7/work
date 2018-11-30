data_dir=/hps/nobackup2/production/ensembl/anja/G2P/
perl $HOME/bin/ensembl-vep/vep \
--cache_version 94 \
--db_version 94 \
--assembly GRCh37 \
--port 3337 \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file $data_dir/input/grch37/debug_variants \
--output_file $data_dir/output/grch37/debug_variants.out \
--force_overwrite \
--cache \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin FrequencyFilter,af_from_vcf=1 \
