perl $HOME/bin/ensembl-vep/vep \
--cache_version 93 \
--db_version 93 \
--dir /hps/nobackup2/production/ensembl/anja/vep/ \
--input_file /hps/nobackup2/production/ensembl/anja/vep_data/input/grch37/Homo_sapiens_clinically_associated.vcf.gz \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/Homo_sapiens_clinically_associated.vcf \
--force_overwrite \
--cache \
--shift_hgvs 0 \
--port 3337 \
--fork 5 \
--buffer_size 100000 \
--force_overwrite \
--vcf \
--per_gene \
#./vep -i /home/denise/process_snps/input.vcf -o /home/denise/process_snps/output.vcf --dir /tools/.vep --cache --shift_hgvs 0 --port 3337 --fork 1 --buffer_size 100000 --force_overwrite --vcf --per_gene 
