data_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
perl  $HOME/bin/ensembl-vep/vep \
--config vep.ini \
--dir /homes/anja/bin/work/vep/18062019/ \
--output_file $data_dir/output/grch37/p1_81.vcf \
-i $data_dir/input/grch37/P1.vcf \
