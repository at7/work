working_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
perl  $HOME/bin/ensembl-vep/vep \
--species homo_sapiens \
--cache \
--offline \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file $working_dir/input/grch37/test270219.vcf \
--output_file $working_dir/output/grch37/test270219.out \
--force_overwrite \
--regulatory \
--cache_version 95 \
--assembly GRCh37 \
#--dir  /nfs/production/panda/ensembl/variation/data/VEP/tabixconverted/ \
