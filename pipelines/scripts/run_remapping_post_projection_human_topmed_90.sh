pipeline_dir=/hps/nobackup/production/ensembl/anja/release_90/human/remapping/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::Remapping_conf \
-pipeline_name remapping_human_90_37 \
-bwa_location /nfs/software/ensembl/RHEL7/linuxbrew/bin/bwa \
-samtools_location /nfs/software/ensembl/RHEL7/linuxbrew/bin/samtools \
-pipeline_dir ${pipeline_dir} \
-new_assembly ${pipeline_dir}new_assembly \
-new_assembly_file_name Homo_sapiens.GRCh37.dna.primary_assembly.fa \
-old_assembly ${pipeline_dir}old_assembly \
-ensembl_release 90 \
-registry_file ${pipeline_dir}ensembl.registry.89.38 \
-registry_file_newasm ${pipeline_dir}ensembl.registry.90.37 \
-species human \
-hive_db_password \
-mode remap_post_projection \
-feature_table_failed_projection variation_feature_topmed_37_failed \
-feature_table_projection variation_feature_topmed_37 \
-run_variant_qc 0 \
