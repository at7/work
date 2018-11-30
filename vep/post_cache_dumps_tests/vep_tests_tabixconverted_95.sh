perl $HOME/bin/ensembl-vep/vep \
--registry /hps/nobackup2/production/ensembl/anja/release_95/human/vep_dumps/ensembl.registry \
--dir /nfs/production/panda/ensembl/variation/data/VEP/tabixconverted/ \
--input_file /hps/nobackup2/production/ensembl/anja/vep_data/input/grch38/homo_sapiens-chr14.vcf.gz \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/grch38/homo_sapiens-chr14_tabixconverted.out \
--force_overwrite \
--cache \
--everything \
