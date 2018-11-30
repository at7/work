perl $HOME/bin/ensembl-vep/vep \
--cache_version 94 \
--db_version 94 \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file /hps/nobackup2/production/ensembl/anja/vep_data/input/grch38/homo_sapiens-chr14.vcf.gz \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/grch38/homo_sapiens-chr14_94.out \
--force_overwrite \
--cache \
--everything \
