HIVE_SRV=mysql-ens-var-prod-1-ensadmin
pipeline_dir=/hps/nobackup2/production/ensembl/anja/release_94/dog/remapping/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::RemappingStructuralVariationFeature_conf \
$($HIVE_SRV details hive) \
-pipeline_name remapping_svs_dog \
-pipeline_dir $pipeline_dir \
-ensembl_release 94 \
-species dog \
