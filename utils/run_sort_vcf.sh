vcf_file=/hps/nobackup2/production/ensembl/anja/release_95/human/dumps/vcf/homo_sapiens/1000GENOMES-phase_3.vcf
vcf_file_gz=/hps/nobackup2/production/ensembl/anja/release_95/human/dumps/vcf/homo_sapiens/1000GENOMES-phase_3.vcf.gz
vcf-sort < $vcf_file | bgzip > $vcf_file_gz
