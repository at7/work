working_dir=/hps/nobackup/production/ensembl/anja/
bsub -q production-rh7 -M 5000 -R "rusage[mem=5000]" -J vep -o $working_dir/vep_data/fork_03_04.out -e $working_dir/vep_data/fork_03_04.err \
perl $HOME/bin/ensembl-vep/vep \
-i $working_dir/vep_data/input/grch37/Homo_sapiens_clinically_associated.vcf.gz  \
-o $working_dir/vep_data/output/fork_grch37_03_04_2018.txt \
--offline \
--dir_cache /hps/nobackup/production/ensembl/anja/vep/ \
--cache_version 83 \
--gtf /hps/nobackup/production/ensembl/anja/vep_data/homo_sapiens_grch37_refseq_genome_sorted.gz \
--fasta /hps/nobackup/production/ensembl/anja/vep_data/Homo_sapiens.GRCh37.dna.primary_assembly.fa \
--format vcf \
--no_stats --hgvs --numbers --symbol --domains --regulatory --protein --biotype --fork 4 --force -o STDOUT --quiet \
--buffer_size 50 \
--force_overwrite \
--refseq \
