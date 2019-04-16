HIVE_SRV=mysql-ens-var-prod-2-ensadmin
species_dir=/hps/nobackup2/production/ensembl/anja/release_97/human/protein_function/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::ProteinFunction::ProteinFunction_conf \
$($HIVE_SRV details hive) \
-pipeline_name protein_function_from_file \
-species_dir ${species_dir} \
-species homo_sapiens \
-dbnsfp_run_type FULL \
-cadd_run_type FULL \
