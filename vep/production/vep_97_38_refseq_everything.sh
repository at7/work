working_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
perl  $HOME/bin/ensembl-vep/vep \
--species homo_sapiens \
--cache \
--offline \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file $working_dir/input/grch38/vep_cache_test.txt \
--output_file $working_dir/output/grch38/vep_cache_test_97_38_refseq.out \
--force_overwrite \
--cache_version 97 \
--assembly GRCh38 \
--everything \
--refseq \
--use_given_ref \
