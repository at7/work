HIVE_SRV=mysql-ens-var-prod-3-ensadmin
pipeline_dir=/hps/nobackup2/production/ensembl/anja/gnomad/20190322/Exomes/remap_gnomad/remapping/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::Remapping::RemappingVariationFeature_conf \
$($HIVE_SRV details hive) \
-pipeline_name remapping_gnomad_exomes_fixed \
-pipeline_dir ${pipeline_dir} \
-ensembl_release 96 \
-species human \
