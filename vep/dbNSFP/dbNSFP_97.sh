working_dir=/hps/nobackup2/production/ensembl/anja/
bsub -q production-rh7 -M 5000 -R "rusage[mem=5000]" -J vep -o $working_dir/vep_data/dbNSFP_grch37.out -e $working_dir/vep_data/dbNSFP_grch37.err \
perl $HOME/bin/ensembl-vep/vep \
-i $working_dir/vep_data/input/grch37/4.0b1a_grch37.vcf  \
-o $working_dir/vep_data/output/grch37/dbnsfp_grch37.out \
--offline \
--cache \
--dir_cache /nfs/production/panda/ensembl/variation/data/VEP/ \
--cache_version 97 \
--assembly GRCh37 \
--plugin dbNSFP,/nfs/production/panda/ensembl/variation/data/dbNSFP/4.0a/dbNSFP4.0a_grch37.gz,/homes/anja/bin/VEP_plugins/dbNSFP_replacement_logic,REVEL_score,VEST4_score,Interpro_domain \
--dir_plugins /homes/anja/bin/VEP_plugins/ \
--force_overwrite \
--tab \
