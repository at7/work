from_database=pan_troglodytes_variation_90_214
to_database=pan_troglodytes_variation_91_214
for table in allele population_genotype tmp_sample_genotype_single_bp variation_feature
do
mysqldump -h mysql-ensembl-mirror.ebi.ac.uk -u ensadmin -p'ensembl' -P 4240 $from_database $table | mysql -h mysql-ens-var-prod-2.ebi.ac.uk -u ensadmin -p'ensembl' -P 4521 $to_database
done 
