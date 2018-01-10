password=$1
pipeline_dir=/hps/nobackup/production/ensembl/anja/release_92/goat/remapping/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::RemappingPostDbSNPImport_conf \
-pipeline_name remapping_goat \
-pipeline_dir ${pipeline_dir} \
-new_assembly ${pipeline_dir}new_assembly \
-new_assembly_file_name capra_hircus_softmasked_toplevel.fa \
-old_assembly ${pipeline_dir}old_assembly \
-ensembl_release 92 \
-registry_file_oldasm ${pipeline_dir}ensembl.registry.oldasm \
-registry_file_newasm ${pipeline_dir}ensembl.registry.newasm \
-species goat \
-hive_db_password $password \
-seq_region_name_mappings_file $pipeline_dir/old_assembly/chromosome_id_mappings \
