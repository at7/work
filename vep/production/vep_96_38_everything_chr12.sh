working_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
perl  $HOME/bin/ensembl-vep/vep \
--species homo_sapiens \
--cache \
--offline \
--dir /hps/nobackup2/production/ensembl/anja/release_96/human/vep_dumps/vertebrates/dumps/ \
--input_file $working_dir/input/grch38/vep_cache_test_chr12.txt \
--output_file $working_dir/output/grch38/vep_cache_test_ch12_96_38.out \
--force_overwrite \
--cache_version 96 \
--assembly GRCh38 \
--everything \
