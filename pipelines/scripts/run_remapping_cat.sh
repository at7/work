pipeline_dir=/lustre/scratch110/ensembl/at7/release_82/cat/remapping/
tools_dir=/nfs/users/nfs_a/at7/tools/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::Remapping_conf \
-pipeline_name remapping_cat \
-bwa_location ${tools_dir}/bwa-0.7.5a \
-samtools_location ${tools_dir}/samtools-0.1.19 \
-pipeline_dir ${pipeline_dir} \
-new_assembly ${pipeline_dir}assembly \
-new_assembly_file_name Felis_catus.Felis_catus_6.2.dna.toplevel.fa \
-old_assembly ${pipeline_dir}old_assembly \
-ensembl_release 82 \
-registry_file ${pipeline_dir}ensembl.registry \
-registry_file_newasm ${pipeline_dir}ensembl.registry \
-species cat \
-hive_db_password \
-use_fasta_files 1 \
-mode remap_from_file \
