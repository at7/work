password=$1
pipeline_dir=/hps/nobackup/production/ensembl/anja/release_91/gibbon/remapping_test_post_projection/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::RemappingPostProjection_conf \
-pipeline_name remapping_gibbon_post_projection \
-pipeline_dir ${pipeline_dir} \
-ensembl_release 91 \
-species gibbon \
-hive_db_password $password \
-feature_table variation_feature_failed \
