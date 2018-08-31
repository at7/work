working_dir=/hps/nobackup2/production/ensembl/anja/
bsub -q production-rh7 -M 5000 -R "rusage[mem=5000]" -J vep -o $working_dir/vep_data/dbnsfp_3.5_grch37.out -e $working_dir/vep_data/dbnsfp_3.5_grch37.err \
perl $HOME/bin/ensembl-vep/vep \
-i $working_dir/vep_data/input/grch37/stefan.vcf  \
-o $working_dir/vep_data/output/stefan_28082018.txt \
--dir_cache /hps/nobackup2/production/ensembl/anja/vep/ \
--cache_version 93 \
--offline \
--dir_plugins /homes/anja/bin/VEP_plugins/ \
--tab \
--assembly GRCh37 \
--plugin dbNSFP,/nfs/production/panda/ensembl/variation/data/dbNSFP/3.5a_grch37/dbNSFP3.5a_grch37.txt.gz,aaref,genename \
--force_overwrite

