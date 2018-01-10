

nomascus_leucogenys_variation_90_1



mysqldump -h mysql-ensembl-mirror.ebi.ac.uk -u ensadmin -p'ensembl'  -P 4240 pan_troglodytes_variation_90_214 population_genotype  | mysql -h mysql-ens-var-prod-2.ebi.ac.uk -u ensadmin -p'ensembl' -P 4521 pan_troglodytes_variation_91_214
