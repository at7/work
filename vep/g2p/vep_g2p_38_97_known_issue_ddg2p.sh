vep_data=/hps/nobackup2/production/ensembl/anja/
perl $HOME/bin/ensembl-vep/vep \
-i ${vep_data}/vep_data/input/grch38/g2p/test.vcf  \
--output_file ${vep_data}/vep_data/output/grch38/g2p/test.out \
--force_overwrite \
--assembly GRCh38 \
--merged \
--use_given_ref \
--cache --cache_version 97 \
--dir_cache /nfs/production/panda/ensembl/variation/data/VEP/  \
--individual all \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin G2P,file="${vep_data}/G2P/autumn2019/DDG2P_9_9_2019.csv",af_from_vcf=1 \
#--plugin G2P,file="${vep_data}/G2P/autumn2019/DDG2P_9_9_2019.csv",af_from_vcf=1 \
#--transcript_filter "gene_symbol in /home/u027/project/resources/genes_in_DDG2P.13062019.txt" \
