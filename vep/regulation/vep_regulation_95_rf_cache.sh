working_dir=/hps/nobackup2/production/ensembl/anja/release_95/human/vep_dumps/motif_feature_tests/
perl  $HOME/bin/ensembl-vep/vep \
--species homo_sapiens \
--cache \
--offline \
--dir /hps/nobackup2/production/ensembl/anja/release_95/vep_dumps/vertebrates/dumps/ \
--input_file $working_dir/input_chrom13.txt \
--output_file $working_dir/output_chrom13.txt \
--force_overwrite \
--regulatory \
--cache_version 95 \
