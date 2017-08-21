vcf_file=/hps/nobackup/production/ensembl/anja/release_90/dumps_90/vcf/nomascus_leucogenys/Nomascus_leucogenys.vcf
vcf_file_gz=/hps/nobackup/production/ensembl/anja/release_90/dumps_90/vcf/nomascus_leucogenys/Nomascus_leucogenys.vcf.gz
vcf-sort < $vcf_file | bgzip > $vcf_file_gz
