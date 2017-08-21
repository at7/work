pipeline_dir=/lustre/scratch109/ensembl/at7/release_87/dumps/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::ReleaseDataDumps::ReleaseDumps_conf \
-pipeline_dir ${pipeline_dir} \
-pipeline_name data_dumps_87 \
-hive_db_host ens-variation2 \
-hive_db_password $password \
-registry_file ${pipeline_dir}ensembl.registry \
-ensembl_release 87 \
-tmp_dir ${pipeline_dir}/tmp_dir \
