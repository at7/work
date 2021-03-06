perl  $HOME/bin/ensembl-vep/vep \
--species homo_sapiens \
--cache \
--offline \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file  /hps/nobackup2/production/ensembl/anja/vep_data/input/regulatory_variant_location.txt \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/regulatory_variant_10012019.txt \
--force_overwrite \
--regulatory \
--cache_version 93 \
--assembly GRCh38 \
