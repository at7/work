pipeline_dir=/hps/nobackup/production/ensembl/anja/release_90/pig/remapping_qtl/
remapping_dir=/hps/nobackup/production/ensembl/anja/release_90/pig/remapping/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::Remapping_conf \
-pipeline_name remapping_qtl_pig \
-bwa_location /homes/anja/bin/bwa \
-samtools_location /nfs/software/ensembl/RHEL7/linuxbrew/bin/samtools \
-pipeline_dir ${pipeline_dir} \
-new_assembly ${remapping_dir}new_assembly \
-new_assembly_file_name  pig_softmasked_toplevel.fa \
-old_assembly ${remapping_dir}old_assembly \
-ensembl_release 90 \
-registry_file ${remapping_dir}ensembl.registry.89 \
-registry_file_newasm ${remapping_dir}ensembl.registry.90 \
-species pig \
-hive_db_password \
-mode remap_qtls \
-feature_table phenotype_feature \
