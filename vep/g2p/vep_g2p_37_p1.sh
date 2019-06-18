vep_data=/hps/nobackup2/production/ensembl/anja/
perl $HOME/bin/ensembl-vep/vep \
--cache --cache_version 90 \
--assembly GRCh37 \
--port 3337 \
--dir /hps/nobackup2/production/ensembl/anja/vep/ \
--input_file ${vep_data}/vep_data/input/grch37/P1.vcf.gz \
--output_file ${vep_data}/vep_data/output/grch37/P1.out \
--force_overwrite \
--individual 'P1' \
#--dir_plugins $HOME/bin/VEP_plugins \
#--plugin G2P,file="${vep_data}/G2P/spring2019/Intellectual_disability.tsv" \
