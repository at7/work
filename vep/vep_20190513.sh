vep_data=/hps/nobackup2/production/ensembl/anja/
perl $HOME/bin/ensembl-vep/vep \
--cache --cache_version 96 \
--db_version 96 \
--assembly GRCh37 \
--port 3337 \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file ${vep_data}/vep_data/input/grch37/input_20190513.txt \
--output_file ${vep_data}/vep_data/output/grch37/output_20190513 \
--force_overwrite \
--fork 4 \
--af --appris --biotype --buffer_size 500 --check_existing --distance 5000 --polyphen b --pubmed --sift b --regulatory \
