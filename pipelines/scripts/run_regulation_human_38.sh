pipeline_name=regulation_effect_38_95
pipeline_dir=/hps/nobackup2/production/ensembl/anja/release_95/human/regulation_effect/
species=human
HIVE_SRV=mysql-ens-var-prod-1-ensadmin
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::RegulationEffect_conf \
$($HIVE_SRV details hive) \
-pipeline_name $pipeline_name \
-pipeline_dir $pipeline_dir  \
-species $species \
