working_dir=/hps/nobackup2/production/ensembl/anja/
bsub -q production-rh7 -M 5000 -R "rusage[mem=5000]" -J vep -o $working_dir/vep_data/dbNSFP_grch38.out -e $working_dir/vep_data/dbNSFP_grch38.err \
perl $HOME/bin/ensembl-vep/vep \
-i $working_dir/vep_data/input/grch38/4.0a_grch38.vcf  \
-o $working_dir/vep_data/output/grch38/dbnsfp_grch38.out \
--offline \
--cache \
--dir_cache /nfs/production/panda/ensembl/variation/data/VEP/ \
--cache_version 97 \
--assembly GRCh38 \
--plugin dbNSFP,/nfs/production/panda/ensembl/variation/data/dbNSFP/4.0a/dbNSFP4.0a_grch38.gz,/homes/anja/bin/VEP_plugins/dbNSFP_replacement_logic,REVEL_score,VEST4_score,Interpro_domain \
--dir_plugins /homes/anja/bin/VEP_plugins/ \
--force_overwrite \
--vcf \
