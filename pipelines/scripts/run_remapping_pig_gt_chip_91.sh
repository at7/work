password=$1
pipeline_dir=/hps/nobackup/production/ensembl/anja/release_91/pig/remapping_genotype_chip/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::RemappingVariationFeature_conf \
-pipeline_name remapping_gt_chip_pig \
-pipeline_dir ${pipeline_dir} \
-ensembl_release 91 \
-species pig \
-hive_db_password $password \
