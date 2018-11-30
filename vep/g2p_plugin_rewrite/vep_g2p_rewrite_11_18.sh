data_dir=/hps/nobackup2/production/ensembl/anja/G2P/
perl $HOME/bin/ensembl-vep/vep \
--db_version 94 \
--cache_version 94 \
--assembly GRCh37 \
--port 3337 \
--dir /hps/nobackup2/production/ensembl/anja/vep/ \
--input_file $data_dir/input/grch37/rachel_43_no_id_sorted.vcf.gz \
--output_file $data_dir/output/grch37/rachel_43_no_id_sorted.out \
--force_overwrite \
--cache \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin G2P,file='/hps/nobackup2/production/ensembl/anja/G2P/DDG2P_15_11_2018.csv',af_from_vcf=1 \
