password=$1
pipeline_dir=/hps/nobackup/production/ensembl/anja/release_92/zebrafish/remapping_svs/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::RemappingStructuralVariationFeature_conf \
-pipeline_name remapping_svs_zebrafish \
-pipeline_dir ${pipeline_dir} \
-ensembl_release 92 \
-species zebrafish \
-hive_db_password $password \
