password=$1
pipeline_dir=/hps/nobackup/production/ensembl/anja/release_91/pig/remapping_test/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::RemappingVariationFeature_conf \
-pipeline_name remapping_test_pig \
-pipeline_dir ${pipeline_dir} \
-ensembl_release 91 \
-species pig \
-hive_db_password $password \
-seq_region_name_mappings_file $pipeline_dir/old_assembly/chromosome_id_mappings \
