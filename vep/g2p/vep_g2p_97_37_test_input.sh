vep_data=/hps/nobackup2/production/ensembl/anja/
perl $HOME/bin/ensembl-vep/vep \
--cache --cache_version 97 \
--db_version 97 \
--assembly GRCh37 \
--dir /nfs/production/panda/ensembl/variation/data/VEP/tabixconverted/ \
--input_file ${vep_data}/vep_data/input/grch37/P1.vcf \
--output_file ${vep_data}/vep_data/output/grch37/P1_10072019.out \
--force_overwrite \
--individual ALL \
--port 3337 \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin G2P,file="${vep_data}/G2P/spring2019/DDG2P_25_4_2019.csv",af_from_vcf=1 \
#--plugin G2P,file="${vep_data}/G2P/spring2019/DDG2P_25_4_2019.csv",af_from_vcf=1 \
