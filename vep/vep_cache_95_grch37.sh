perl $HOME/bin/ensembl-vep/vep \
--cache_version 95 \
--db_version 95 \
--dir /nfs/production/panda/ensembl/variation/data/VEP/tabixconverted/ \
--input_file /hps/nobackup2/production/ensembl/anja/vep_data/input/grch37/i-ensemble-annotated.vcf \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/grch37/i-ensemble-annotated.out \
--force_overwrite \
--cache \
--offline \
--assembly GRCh37 \
--shift_hgvs 1 \
--port 3337 \
--fork 4 \
--buffer_size 500 \
--force_overwrite \
--af \
--appris \
--biotype \
--check_existing \
--coding_only \
--distance 5000 \
--filter_common \
--polyphen b \
--pubmed \
--sift b \
--symbol \
--tsl \
--regulatory \
