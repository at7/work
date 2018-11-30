HIVE_SRV=mysql-ens-var-prod-1-ensadmin
pipeline_dir=/hps/nobackup2/production/ensembl/anja/release_95/horse/remapping_sv/
remapping_dir=/hps/nobackup2/production/ensembl/anja/release_95/horse/remapping/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::RemappingStructuralVariationFeature_conf \
$($HIVE_SRV details hive) \
-pipeline_name remapping_sv_horse \
-pipeline_dir $pipeline_dir \
-ensembl_release 95 \
-species horse \
-registry_file_oldasm $remapping_dir/ensembl.registry.oldasm \
-registry_file_newasm $remapping_dir/ensembl.registry.newasm \
-old_assembly $remapping_dir/old_assembly \
-new_assembly $remapping_dir/new_assembly \
