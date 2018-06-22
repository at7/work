working_dir=/hps/nobackup2/production/ensembl/anja/
perl $HOME/bin/ensembl-vep/haplo \
-i $working_dir/vep_data/input/grch38/input_haplo.vcf \
-o $working_dir/vep_data/output/output_haplo \
--cache \
--dir_cache /hps/nobackup2/production/ensembl/anja/vep/ \
--cache_version 92 \
--species homo_sapiens \
