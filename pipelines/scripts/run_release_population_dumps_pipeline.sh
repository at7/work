pipeline_dir=/hps/nobackup/production/ensembl/anja/release_90/dumps_human_37/population/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::ReleaseDataDumps::PopulationDumps_conf \
-pipeline_dir ${pipeline_dir} \
-pipeline_name population_dumps_90_37 \
-hive_db_host mysql-ens-var-prod-2.ebi.ac.uk \
-hive_db_password  \
-hive_db_port  \
-hive_db_user  \
-registry_file ${pipeline_dir}ensembl.registry \
-ensembl_release 90 \
-tmp_dir ${pipeline_dir}/tmp \
-prefetched_frequencies /hps/nobackup/production/ensembl/anja/allele_frequencies/ \
-gvf_validator /homes/anja/bin/GAL/bin/gvf_validator \
-so_file /homes/anja/bin/SO-Ontologies/so.obo \
