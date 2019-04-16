working_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
perl  $HOME/bin/ensembl-vep/vep \
--species homo_sapiens \
--cache \
--offline \
--dir /hps/nobackup2/production/ensembl/anja/release_96/human/GRCh37/vep_dumps/vertebrates/dumps/ \
--input_file $working_dir/input/grch37/production_test_96_37.vcf \
--output_file $working_dir/output/grch37/production_test_37.out \
--force_overwrite \
--cache_version 96 \
--assembly GRCh37 \
--af_gnomad \
#--dir  /nfs/production/panda/ensembl/variation/data/VEP/tabixconverted/ \
