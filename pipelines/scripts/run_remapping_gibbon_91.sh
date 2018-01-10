password=$1
pipeline_dir=/hps/nobackup/production/ensembl/anja/release_91/gibbon/remapping/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::RemappingVariationFeature_conf \
-pipeline_name remapping_gibbon \
-pipeline_dir ${pipeline_dir} \
-ensembl_release 91 \
-species gibbon \
-hive_db_password $password \
