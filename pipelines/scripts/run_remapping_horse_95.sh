HIVE_SRV=mysql-ens-var-prod-1-ensadmin
pipeline_dir=/hps/nobackup2/production/ensembl/anja/release_95/horse/remapping/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::RemappingVariationFeature_conf \
$($HIVE_SRV details hive) \
-pipeline_name remapping_horse \
-pipeline_dir ${pipeline_dir} \
-ensembl_release 95 \
-species horse \
