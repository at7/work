pipeline_dir=/hps/nobackup/production/ensembl/anja/release_88/dumps/gvf/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::ReleaseDataDumps::ReleaseDumps_conf \
-pipeline_dir ${pipeline_dir} \
-pipeline_name gvf_no_human_dumps_88 \
-hive_db_host mysql-ens-var-prod-1.ebi.ac.uk \
-hive_db_password  \
-hive_db_port  \
-hive_db_user  \
-registry_file ${pipeline_dir}ensembl.registry \
-ensembl_release 88 \
-dump_only_gvf 1 \
-gvf_validator /homes/anja/bin/GAL/bin/gvf_validator \
-so_file /homes/anja/bin/SO-Ontologies/so.obo \
-tmp_dir ${pipeline_dir}/tmp_dir \
