pipeline_name=regulation_effect_37_95
pipeline_dir=/hps/nobackup2/production/ensembl/anja/release_95/human/grch37/regulation_effect/
species=human
HIVE_SRV=mysql-ens-var-prod-3-ensadmin
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::RegulationEffect_conf \
$($HIVE_SRV details hive) \
-pipeline_name $pipeline_name \
-pipeline_dir $pipeline_dir  \
-species $species \
