data_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
vep_cache_dir=/nfs/production/panda/ensembl/variation/data/VEP/
perl /homes/anja/bin/ensembl-tools/scripts/variant_effect_predictor/variant_effect_predictor.pl \
--vcf \
--hgvs \
--offline \
--dir_cache $vep_cache_dir \
--format vcf \
--output_file $data_dir/output/grch37/congenica_test_grch37.out \
--input_file $data_dir/input/grch37/congenica_test_grch37.vcf.gz \
--no_progress --force_overwrite --no_stats \
--fasta /nfs/production/panda/ensembl/variation/data/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa \
--merged \
--all_refseq \
--assembly GRCh37 \
--compress zcat \
--buffer_size 100 \
--fork 4 \
--everything \
