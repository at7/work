perl  $HOME/bin/ensembl-vep/vep \
--species human \
--database \
--db_version 94 \
--host mysql-ensembl-mirror \
--port 4240 \
--user ensro \
--input_file  /hps/nobackup2/production/ensembl/anja/vep_data/input/regulatory_variant_id.txt \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/regulatory_variant_mf_db.txt \
--force_overwrite \
--regulatory \
