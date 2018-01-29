working_dir=/hps/nobackup/production/ensembl/anja/
bsub -q production-rh7 -M 5000 -R "rusage[mem=5000]" -J vep -o $working_dir/vep_data/gff_annotation.out -e $working_dir/vep_data/gff_annotation.err \
perl $HOME/bin/ensembl-vep/vep \
-i $working_dir/vep_data/input/rachel_43_no_id_sorted.vcf  \
-o $working_dir/vep_data/output/gff_annotation_2018_01_18_grch37_gff_only.txt \
--gff $working_dir/vep_data/release_91/Homo_sapiens.GRCh37.87.chr.gff3.gz \
--fasta $working_dir/vep_data/release_91/Homo_sapiens.GRCh37.dna.primary_assembly.fa.gz \
#--offline \
#--gff $working_dir/vep_data/release_91/Homo_sapiens.GRCh37.87.chr.gff3.gz \
#--fasta $working_dir/vep_data/release_91/Homo_sapiens.GRCh37.dna.primary_assembly.fa.gz \
#--cache \
#--dir_cache /hps/nobackup/production/ensembl/anja/vep/ \
#--assembly GRCh37 \
#--port 3337 \
#--cache \
#--dir_cache /hps/nobackup/production/ensembl/anja/vep/ \
#/vep -i 1000GENOMES-phase_3.vcf --cache --port 3337 --canonical --symbol --vcf -o 1000Genomes_1.vcf
#-i /hps/nobackup/production/ensembl/anja/release_91/dumps_91/vcf/homo_sapiens/1000GENOMES-phase_3.vcf.gz \
#--fields Uploaded_variation, Consequence, CANONICAL, SYMBOL \
#--cache \
#--port 3337 \
#--dir_cache /hps/nobackup/production/ensembl/anja/release_90/vep_37/ \
#--cache_version 90 \
#-o /hps/nobackup/production/ensembl/anja/1000Genomes.out
#-i input_suspicious.txt \
#--output_file test_vep_dumps_37.out \
#--force_overwrite \
#--assembly GRCh37 \
#--port 3337 \
#--cache \
#--cache_version 90 \
#--dir_cache /hps/nobackup/production/ensembl/anja/release_90/vep_37/ \
#--species homo_sapiens \
#--everything \
#1000GENOMES-phase_3.vcf.gz
