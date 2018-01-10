password=$1
pipeline_dir=/hps/nobackup/production/ensembl/anja/release_91/pig/remapping/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::RemappingQTL_conf \
-pipeline_name remapping_qtl_pig \
-pipeline_dir ${pipeline_dir} \
-ensembl_release 91 \
-species pig \
-hive_db_password $password \
