vcf_file=
vcf_file=/hps/nobackup/production/ensembl/anja/release_91/dumps_human/vcf/homo_sapiens/1000GENOMES-phase_3.vcf
vcf_file_gz=/hps/nobackup/production/ensembl/anja/release_91/dumps_human/vcf/homo_sapiens/1000GENOMES-phase_3.vcf.gz
vcf-sort < $vcf_file | bgzip > $vcf_file_gz
