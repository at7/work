vcf_file=/gpfs/nobackup/ensembl/anja/release_92/grch37/dumps/vcf/homo_sapiens/1000GENOMES-phase_3.vcf
vcf_file_gz=/gpfs/nobackup/ensembl/anja/release_92/grch37/dumps/vcf/homo_sapiens/1000GENOMES-phase_3.vcf.gz
vcf-sort < $vcf_file | bgzip > $vcf_file_gz
