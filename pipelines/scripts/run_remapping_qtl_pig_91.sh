password=$1
pipeline_dir=/hps/nobackup/production/ensembl/anja/release_91/pig/remapping/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::RemappingPhenotypeFeature_conf \
-pipeline_name remapping_qtl_pig \
-pipeline_dir ${pipeline_dir} \
-new_assembly ${pipeline_dir}new_assembly \
-new_assembly_file_name pig_softmasked_toplevel.fa \
-old_assembly ${pipeline_dir}old_assembly \
-ensembl_release 91 \
-registry_file_oldasm ${pipeline_dir}ensembl.registry.oldasm \
-registry_file_newasm ${pipeline_dir}ensembl.registry.newasm \
-species pig \
-hive_db_password $password \
