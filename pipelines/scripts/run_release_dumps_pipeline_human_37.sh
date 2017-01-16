password=$1
pipeline_dir=/hps/nobackup/production/ensembl/anja/release_88/dumps/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::ReleaseDataDumps::ReleaseDumps_conf \
-pipeline_dir ${pipeline_dir} \
-pipeline_name data_dumps_87_human_37 \
-hive_db_host mysql-ens-var-prod-1.ebi.ac.uk \
-hive_db_port 4449 \
-hive_db_password $password \
-hive_db_user ensadmin \
-gvf_validator /homes/anja/bin/GAL/bin/gvf_validator \
-so_file /homes/anja/bin/SO-Ontologies/so.obo \
-registry_file ${pipeline_dir}ensembl.registry \
-ensembl_release 87 \
-prefetched_frequencies /hps/nobackup/production/ensembl/anja/release_88/dumps/allele_frequencies/ \
-tmp_dir ${pipeline_dir}/tmp_dir \
