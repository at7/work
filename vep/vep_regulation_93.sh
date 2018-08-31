perl  $HOME/bin/ensembl-vep/vep \
--species human \
--cache \
--cache_version 93 \
--dir /hps/nobackup2/production/ensembl/anja/vep/ \
--input_file  /hps/nobackup2/production/ensembl/anja/vep_data/input/regulatory_variant.txt \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/regulatory_variant.txt \
--force_overwrite \
--regulatory \
