from_database=sus_scrofa_core_89_102
to_database=anja_sus_scrofa_variation_91_111
for table in seq_region
do
mysqldump -h mysql-ensembl-mirror.ebi.ac.uk -u ensadmin -p'ensembl' -P 4240 $from_database $table | mysql -h mysql-ens-var-prod-2.ebi.ac.uk -u ensadmin -p'ensembl' -P 4521 $to_database
done 
