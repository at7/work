working_dir=/hps/nobackup/production/ensembl/anja/
bsub -q production-rh7 -M 5000 -R "rusage[mem=5000]" -J vep -o $working_dir/vep_data/dbnsfp_2.9_grch37.out -e $working_dir/vep_data/dbnsfp_2.9_grch37.err \
perl $HOME/bin/ensembl-vep/vep \
-i $working_dir/vep_data/input/rachel_43_no_id_sorted.vcf  \
-o $working_dir/vep_data/output/dbnsfp_2.9_grch37.txt \
--port 3337 \
--cache \
--dir_cache /hps/nobackup/production/ensembl/anja/vep/ \
--dir_plugins /homes/anja/bin/VEP_plugins/ \
--plugin dbNSFP,/nfs/production/panda/ensembl/variation/data/dbNSFP/2.9.2/dbNSFP2.9.2.txt.gz,Interpro_domain \
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
