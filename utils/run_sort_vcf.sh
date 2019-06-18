vcf_file=/hps/nobackup2/production/ensembl/anja/release_97/human/dumps/vertebrates/homo_sapiens_incl_consequences-chr10.vcf
vcf_file_gz=/hps/nobackup2/production/ensembl/anja/release_97/human/dumps/vertebrates/homo_sapiens_incl_consequences-chr10.vcf.gz
vcf-sort -t /hps/nobackup2/production/ensembl/anja/ < $vcf_file | bgzip > $vcf_file_gz
