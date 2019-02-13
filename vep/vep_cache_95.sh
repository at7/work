perl $HOME/bin/ensembl-vep/vep \
--cache_version 93 \
--db_version 93 \
--dir /hps/nobackup2/production/ensembl/anja/vep/ \
--input_file /hps/nobackup2/production/ensembl/anja/vep_data/input/grch37/ALL.chr22.phase3_shapeit2_mvncall_integrated_v3plus_nounphased.rsID.genotypes.vcf.gz \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/ALL.chr22.phase3_shapeit2_mvncall_integrated_v3plus_nounphased.rsID.genotypes.vcf \
--force_overwrite \
--cache \
--offline \
--assembly GRCh37 \
--fasta /hps/nobackup2/production/ensembl/anja/vep_data/Homo_sapiens.GRCh37.dna.primary_assembly.fa.gz \
--shift_hgvs 1 \
--port 3337 \
--fork 5 \
--buffer_size 1000 \
--force_overwrite \
--per_gene \
#./vep -i /home/denise/process_snps/input.vcf -o /home/denise/process_snps/output.vcf --dir /tools/.vep --cache --shift_hgvs 0 --port 3337 --fork 1 --buffer_size 100000 --force_overwrite --vcf --per_gene 
