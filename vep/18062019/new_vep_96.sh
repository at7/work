data_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
vep_cache_dir=/nfs/production/panda/ensembl/variation/data/VEP/tabixconverted/
perl  $HOME/bin/ensembl-vep/vep \
--cache_version 96 \
--dir $vep_cache_dir \
--output_file $data_dir/output/grch38/12062019/3903.2vars.VEP.vcf \
--force_overwrite \
--cache \
--offline \
--assembly GRCh38 \
--input_file $HOME/test5.vcf \
#--input_file /homes/anja/bin/ensembl-vep/t/testdata/input/test5.vcf \
#--input_file $data_dir/input/grch38/12062019/3903.2vars.vcf \
#--input_file /homes/anja/bin/ensembl-vep/t/testdata/input/test5.vcf \
