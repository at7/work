data_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
vep_cache_dir=/nfs/production/panda/ensembl/variation/data/VEP/tabixconverted/
perl  $HOME/bin/ensembl-vep/haplo \
--cache_version 96 \
--db_version 96 \
--dir $vep_cache_dir \
--output_file $data_dir/output/grch37/haplo.out \
--force_overwrite \
--input_file $data_dir/input/grch37/haplo/input.vcf \
--assembly GRCh37 \
--offline \
--refseq \
--json \
--transcript_filter "stable_id match NM_001220765.2"
