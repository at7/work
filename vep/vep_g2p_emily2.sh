perl $HOME/bin/ensembl-vep/vep \
--dir /hps/nobackup2/production/ensembl/anja/vep/ \
--input_file /hps/nobackup2/production/ensembl/anja/vep_data/input/grch38/CDLS_full.vcf \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/CDLS_full.out \
--force_overwrite \
--cache \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin G2P,file='/homes/anja/bin/work/vep/DDG2P.csv' \
