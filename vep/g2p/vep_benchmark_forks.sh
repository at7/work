data_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
perl $HOME/bin/ensembl-vep/vep \
--dir /nfs/production/panda/ensembl/variation/data/VEP/tabixconverted/ \
--input_file $data_dir/input/grch37/homo_sapiens_clinically_associated.vcf.gz \
--output_file $data_dir/output/grch37/homo_sapiens_clinically_associated_with_forks.out \
--force_overwrite \
--cache \
--fork 4 \
