HIVE_SRV=mysql-ens-var-prod-1-ensadmin
species_dir=/hps/nobackup2/production/ensembl/anja/release_98/human/protein_function/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::ProteinFunction::ProteinFunction_conf \
$($HIVE_SRV details hive) \
-pipeline_name hive_protein_function_from_file_98 \
-species_dir ${species_dir} \
-species homo_sapiens \
-dbnsfp_run_type 1 \
-cadd_run_type 1 \
-include_lrg 1 \
-include_refseq 1 \
