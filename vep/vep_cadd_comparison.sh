perl $HOME/bin/ensembl-vep/vep \
--dir /hps/nobackup2/production/ensembl/anja/vep/ \
--cache_version 94 \
--db_version 94 \
--assembly GRCh37 \
--check_ref \
--port 3337 \
--input_file /hps/nobackup2/production/ensembl/anja/vep_data/input/grch37/variants_cadd \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/grch37/variants_cadd.out \
--force_overwrite \
--cache \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin dbNSFP,/nfs/production/panda/ensembl/variation/data/dbNSFP/3.5a_grch37/dbNSFP3.5a_grch37.txt.gz,CADD_raw,CADD_raw_rankscore,CADD_phred \
--plugin CADD,'/nfs/production/panda/ensembl/variation/data/CADD/v1.3/CADD_InDels.tsv.gz','/nfs/production/panda/ensembl/variation/data/CADD/v1.3/CADD.tsv.gz' \
