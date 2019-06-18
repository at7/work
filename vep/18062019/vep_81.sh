data_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
vep_cache_dir=/nfs/production/panda/ensembl/variation/data/VEP/
perl /homes/anja/bin/ensembl-tools/scripts/variant_effect_predictor/variant_effect_predictor.pl \
--vcf \
--hgvs \
--offline \
--everything \
--dir_cache $vep_cache_dir \
--format vcf \
--output_file $data_dir/output/grch37/p1_81.vcf \
--input_file $data_dir/input/grch37/P1.vcf \
--no_progress --force_overwrite --no_stats \
--fasta /nfs/production/panda/ensembl/variation/data/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa \
--merged \
--all_refseq \
--assembly GRCh37 \
--compress zcat \
--fork 2 \
