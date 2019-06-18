vep_data=/hps/nobackup2/production/ensembl/anja/
perl $HOME/bin/ensembl-vep/vep \
--cache --cache_version 90 \
--assembly GRCh37 \
--port 3337 \
--dir /hps/nobackup2/production/ensembl/anja/vep/ \
--individual P1
--input_file ${vep_data}/vep_data/input/grch37/all_grch37.vcf.gz \
--output_file ${vep_data}/vep_data/output/all_grch37.out \
--force_overwrite \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin G2P,file="${vep_data}/G2P/spring2019/Intellectual_disability.tsv" \
