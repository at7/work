perl $HOME/bin/ensembl-vep/vep \
--cache_version 95 \
--db_version 95 \
--dir /nfs/production/panda/ensembl/variation/data/VEP/tabixconverted/ \
--input_file /hps/nobackup2/production/ensembl/anja/vep_data/input/grch37/tcga-pancan-germline.regions.sorted.vcf \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/grch37/tcga-pancan-germline.regions.sorted.out \
--force_overwrite \
--cache \
--offline \
--assembly GRCh37 \
--port 3337 \
--af \
--appris \
--biotype \
--buffer_size 500 \
--check_existing \
--distance 5000 \
--polyphen b \
--pubmed \
--regulatory \
--sift b \
--symbol \
--tsl \