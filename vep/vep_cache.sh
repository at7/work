perl  $HOME/bin/ensembl-vep/vep \
--cache \
--dir /hps/nobackup2/production/ensembl/anja/release_93/vep_dumps//dumps/qc/b11c5cc92d94fd1c21393386e1c19016 \
--host mysql-ens-var-prod-1 \
--port 4449 \
--refseq \
--user ensro \
--input_file /hps/nobackup2/production/ensembl/anja/release_93/vep_dumps//dumps/qc/homo_sapiens_GRCh38_human_frequency_test_input.txt \
--cache_version 93 \
--is_multispecies 0 \
--output_format tab \
--force_overwrite \
--af_1kg \
--failed 1 \
--af_gnomad \
--db_version 93 \
--buffer_size 1 \
--assembly GRCh38 \
