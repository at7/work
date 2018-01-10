from_database=mus_musculus_variation_90_38
to_database=mus_musculus_variation_91_38
for table in sample 
do
mysqldump -h mysql-ensembl-mirror.ebi.ac.uk -u ensadmin -p'ensembl' -P 4240 $from_database $table | mysql -h mysql-ens-var-prod-2.ebi.ac.uk -u ensadmin -p'ensembl' -P 4521 $to_database
done 
