HIVE_SRV=mysql-ens-var-prod-1-ensadmin
pipeline_dir=/hps/nobackup2/production/ensembl/anja/release_98/ancestral_alleles/
compara_dir=/hps/nobackup2/production/ensembl/anja/release_98/ancestral_alleles/compara_data/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::AncestralAlleles::AncestralAlleles_conf \
$($HIVE_SRV details hive) \
-pipeline_name hive_aa_new_dbsnp_98 \
-pipeline_dir ${pipeline_dir} \
-compara_dir ${compara_dir}
