HIVE_SRV=mysql-ens-var-prod-2-ensadmin
pipeline_dir=/hps/nobackup/production/ensembl/anja/release_92/zebrafish/remapping_test/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::RemappingVariationFeature_conf \
$($HIVE_SRV details hive) \
-pipeline_name remapping_flow_chart \
-pipeline_dir ${pipeline_dir} \
-ensembl_release 92 \
-species zebrafish \
