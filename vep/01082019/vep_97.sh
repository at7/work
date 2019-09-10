data_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
vep_cache_dir=/nfs/production/panda/ensembl/variation/data/VEP/tabixconverted/
perl  $HOME/bin/ensembl-vep/vep \
--dir_cache $vep_cache_dir \
-offline --assembly GRCh38 \
--input_file $data_dir/input/grch38/combined.n2.vcf.Q30d15.vcf.txt \
--output_file $data_dir/output/grch38/combined.n2.vcf.Q30d15.out \
--verbose \
--force_overwrite \
