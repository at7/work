HIVE_SRV=mysql-ens-var-prod-2-ensadmin
pipeline_dir=/hps/nobackup2/production/ensembl/anja/release_97/ancestral_alleles/
compara_dir=$pipeline_dir/compara_data/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::AncestralAlleles::AncestralAlleles_conf \
$($HIVE_SRV details hive) \
-pipeline_name hive_ancestral_alleles_human_97 \
-pipeline_dir ${pipeline_dir} \
-compara_dir ${compara_dir}
