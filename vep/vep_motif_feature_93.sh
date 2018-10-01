perl $HOME/bin/ensembl-vep/vep \
--db_version 93 \
--input_file /hps/nobackup2/production/ensembl/anja/vep_data/input/motif_feature.txt \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/motif_feature.out \
--force_overwrite \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin MotifFeature \
--database \
