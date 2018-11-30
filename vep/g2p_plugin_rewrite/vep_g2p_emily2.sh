perl $HOME/bin/ensembl-vep/vep \
--cache_version 94 \
--db_version 94 \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file /hps/nobackup2/production/ensembl/anja/vep_data/input/grch38/CDLS_full.vcf \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/CDLS_full.out \
--force_overwrite \
--cache \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin G2P,file='/hps/nobackup2/production/ensembl/anja/G2P/DDG2P_15_11_2018.csv' \
