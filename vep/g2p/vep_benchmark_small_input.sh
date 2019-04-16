data_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
perl -d $HOME/bin/ensembl-vep/vep \
--dir /nfs/production/panda/ensembl/variation/data/VEP/tabixconverted/ \
--input_file $data_dir/input/grch38/rs200984506.vcf \
--output_file $data_dir/output/grch38/rs200984506.out \
--force_overwrite \
--cache \
