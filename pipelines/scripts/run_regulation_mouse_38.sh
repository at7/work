pipeline_name=regulation_effect_38_98
pipeline_dir=/hps/nobackup2/production/ensembl/anja/release_98/mouse/regulation_effect/
species=mouse
HIVE_SRV=mysql-ens-var-prod-3-ensadmin
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::RegulationEffect_conf \
$($HIVE_SRV details hive) \
-pipeline_name $pipeline_name \
-pipeline_dir $pipeline_dir  \
-species $species \
