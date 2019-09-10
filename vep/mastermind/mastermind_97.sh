working_dir=/hps/nobackup2/production/ensembl/anja/
bsub -q production-rh7 -M 5000 -R "rusage[mem=5000]" -J vep -o $working_dir/vep_data/mastermind_grch37.out -e $working_dir/vep_data/mastermind_grch37.err \
perl $HOME/bin/ensembl-vep/vep \
-i $working_dir/vep_data/input/grch37/rs699.vcf  \
-o $working_dir/vep_data/output/grch37/mastermind_grch37.csv \
--database --db_version 97 \
--dir_cache /nfs/production/panda/ensembl/variation/data/VEP/ \
--cache_version 97 \
--port 3337 \
--assembly GRCh37 \
--plugin Mastermind,'/nfs/production/panda/ensembl/variation/data/MasterMind/grch37/mastermind_cited_variants_reference-2019.06.14-grch37.vcf.gz' \
--dir_plugins /homes/anja/bin/VEP_plugins/ \
--force_overwrite \
--tab \
