HIVE_SRV=mysql-ens-var-prod-3-ensadmin
pipeline_dir=/hps/nobackup2/production/ensembl/anja/release_96/cat/transcript_variation/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::VariationConsequence_conf \
$($HIVE_SRV details hive) \
-ensembl_cvs_root_dir "$HOME/bin" \
-hive_root_dir "$HOME/bin/ensembl-hive" \
-pipeline_name cat_test_tv_95 \
-pipeline_dir ${pipeline_dir} \
-species cat \
-sort_variation_feature 1 \
-run_variation_class 1 \
