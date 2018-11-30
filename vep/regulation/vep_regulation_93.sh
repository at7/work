perl  $HOME/bin/ensembl-vep/vep \
--species human \
--database \
--host mysql-ensembl-mirror \
--port 4240 \
--user ensro \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file  /hps/nobackup2/production/ensembl/anja/vep_data/input/regulatory_variant.txt \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/regulatory_variant.txt \
--force_overwrite \
--regulatory \