data_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
vep_cache_dir=/nfs/production/panda/ensembl/variation/data/VEP/tabixconverted/
perl  $HOME/bin/ensembl-vep/vep \
--dir_cache $vep_cache_dir \
--cache_version 97 \
-database --db_version 97 --assembly GRCh37 --port 3337 \
--input_file $data_dir/input/grch37/rs371305189.txt \
--output_file $data_dir/output/grch37/rs371305189.out \
--verbose \
--force_overwrite \
--dir_plugins /homes/anja/bin/VEP_plugins/ \
--plugin FunMotifs,/nfs/production/panda/ensembl/variation/data/Funmotifs/blood.funmotifs_sorted.bed.gz
