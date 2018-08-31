perl $HOME/bin/ensembl-vep/vep \
--cache_version 93 \
--db_version 93 \
--dir /hps/nobackup2/production/ensembl/anja/vep/ \
--input_file /hps/nobackup2/production/ensembl/anja/vep_data/input/grch38/NF_full.vcf \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/NF_full.out \
--force_overwrite \
--cache \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin G2P,file='/homes/anja/bin/work/vep/DDG2P_13_8_2018.csv' \
