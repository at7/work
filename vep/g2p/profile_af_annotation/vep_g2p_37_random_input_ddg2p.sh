vep_data=/hps/nobackup2/production/ensembl/anja/
working_dir=/hps/nobackup2/production/ensembl/anja/G2P/profile_frequency_annotation/
bsub -J vep -o $working_dir/91.out -e $working_dir/91.err \
perl $HOME/bin/ensembl-vep/vep \
--cache --cache_version 96 \
--db_version 96 \
--port 3337 \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file ${vep_data}/vep_data/input/grch37/three_individuals.vcf.gz \
--output_file ${vep_data}/vep_data/output/grch37/three_individuals.out \
--force_overwrite \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin G2P,file="${vep_data}/G2P/spring2019/DDG2P_25_4_2019.csv",af_from_vcf=1,af_monoallelic=0.6 \
#--plugin AF_FROM_VCF,file="${vep_data}/G2P/spring2019/Intellectual_disability.tsv",af_from_vcf=1 \
#--plugin AF_FROM_VCF,file="${vep_data}/G2P/spring2019/Intellectual_disability.tsv",af_from_vcf=1 \
#--plugin G2P,file="${vep_data}/G2P/spring2019/DDG2P_25_4_2019.csv" \
#--assembly GRCh37 \
