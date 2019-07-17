HIVE_SRV=mysql-ens-var-prod-3-ensadmin
pipeline_dir=/hps/nobackup2/production/ensembl/anja/release_98/opossum/remapping_no_prior/
remapping_dir=/hps/nobackup2/production/ensembl/anja/release_98/opossum/remapping/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::RemappingVariationFeature_conf \
$($HIVE_SRV details hive) \
-pipeline_name remapping_vf \
-pipeline_dir ${pipeline_dir} \
-ensembl_release 98 \
-species opossum \
-registry_file_oldasm $remapping_dir/ensembl.registry.oldasm \
-registry_file_newasm $remapping_dir/ensembl.registry.newasm \
-old_assembly $remapping_dir/old_assembly \
-new_assembly $remapping_dir/new_assembly \
