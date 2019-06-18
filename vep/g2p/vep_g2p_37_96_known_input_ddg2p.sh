vep_data=/hps/nobackup2/production/ensembl/anja/
perl $HOME/bin/ensembl-vep/vep \
--cache --cache_version 96 \
--assembly GRCh37 \
--port 3337 \
--db_version 96 \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file ${vep_data}/vep_data/input/grch37/test_create_one_with_all_ref_sorted.vcf.gz \
--output_file ${vep_data}/vep_data/output/grch37/test_create_one_with_all_ref_sorted_20190509.out \
--force_overwrite \
--individual ALL \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin G2P,file="${vep_data}/G2P/spring2019/DDG2P_25_4_2019.csv" \
