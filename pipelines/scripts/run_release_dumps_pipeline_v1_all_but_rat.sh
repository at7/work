pipeline_dir=/hps/nobackup/production/ensembl/anja/release_88/dumps/v1_all_but_rat/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::ReleaseDataDumps::ReleaseDumps_conf \
-pipeline_dir ${pipeline_dir} \
-pipeline_name v1_all_but_rat_dumps \
-hive_db_host mysql-ens-var-prod-2.ebi.ac.uk \
-hive_db_password  \
-hive_db_port  \
-hive_db_user  \
-registry_file ${pipeline_dir}ensembl.registry \
-ensembl_release 88 \
-gvf_validator /homes/anja/bin/GAL/bin/gvf_validator \
-so_file /homes/anja/bin/SO-Ontologies/so.obo \
-tmp_dir ${pipeline_dir}/tmp_dir \
