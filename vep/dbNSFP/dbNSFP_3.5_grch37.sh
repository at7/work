working_dir=/hps/nobackup2/production/ensembl/anja/
bsub -q production-rh7 -M 5000 -R "rusage[mem=5000]" -J vep -o $working_dir/vep_data/dbnsfp_3.5_grch37.out -e $working_dir/vep_data/dbnsfp_3.5_grch37.err \
perl $HOME/bin/ensembl-vep/vep \
-i $working_dir/vep_data/input/grch37/Homo_sapiens_clinically_associated.vcf.gz  \
-o $working_dir/vep_data/output/dbnsfp_3.5_grch37.txt \
--port 3337 \
--cache \
--dir_cache /hps/nobackup2/production/ensembl/anja/vep/ \
--cache_version 93 \
--dir_plugins /homes/anja/bin/VEP_plugins/ \
--plugin dbNSFP,/nfs/public/release/ensweb-data/tools/grch37/e93/vep/plugin_data/dbNSFP3.5a_grch37.txt.gz,LRT_pred,MutationTaster_pred,MutationAssessor_pred,FATHMM_pred \
--force_overwrite \
#--gff $working_dir/vep_data/release_91/Homo_sapiens.GRCh38.91.chr.gff3.gz \
#--fasta $working_dir/vep_data/release_91/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz \
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
#--plugin dbNSFP,/nfs/production/panda/ensembl/variation/data/dbNSFP/3.5a_grch37/dbNSFP3.5a_grch37.txt.gz,LRT_pred,MutationTaster_pred,MutationAssessor_pred,FATHMM_pred \

