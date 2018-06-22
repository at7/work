working_dir=/hps/nobackup2/production/ensembl/anja/
data_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
log_file=rest_output_test
bsub -q production-rh7 -M 5000 -R "rusage[mem=5000]" -J vep -o $data_dir/${log_file}.out -e $data_dir/${log_file}.err \
perl $HOME/bin/ensembl-vep/vep \
-i $data_dir/input/id.txt \
-o $data_dir/output/rest.json \
--cache \
--dir_cache $working_dir/vep/ \
--force_overwrite \
--everything \
--species human \
--db_version 92 \
--json \
