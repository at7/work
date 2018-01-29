bsub -q production-rh7 -M 5000 -R "rusage[mem=5000]" -J vep -o out -e err \
perl $HOME/bin/ensembl-vep/vep \
-i /hps/nobackup/production/ensembl/anja/grch37/1000GENOMES-phase_3.vcf \
--canonical \
--symbol \
--cache \
--port 3337 \
--dir_cache /hps/nobackup/production/ensembl/anja/vep/ \
--vcf \
-o /hps/nobackup/production/ensembl/anja/grch37/1000Genomes_3.vcf \
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
