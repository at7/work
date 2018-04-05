from_database=ovis_aries_variation_90_31
to_database=ovis_aries_SNP50_HDSNP_31
for table in allele failed_variation  
do
mysqldump -h mysql-ensembl-mirror.ebi.ac.uk -u ensadmin -p'ensembl' -P 4240 $from_database $table | mysql -h mysql-ens-var-prod-2.ebi.ac.uk -u ensadmin -p'ensembl' -P 4521 $to_database
done 
