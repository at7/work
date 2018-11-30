pipeline_name=remap_vcf_horse
pipeline_dir=/hps/nobackup2/production/ensembl/anja/release_95/horse/remapping_vcf/
population=PRJEB9799
species=horse
vcf_file_name=fixed2.vcf.gz
HIVE_SRV=mysql-ens-var-prod-1-ensadmin
init_pipeline.pl Bio::EnsEMBL::IntVar::Pipeline::NextGen::RemappingVCF::RemappingVCF_conf \
$($HIVE_SRV details hive) \
-pipeline_name $pipeline_name \
-pipeline_dir $pipeline_dir  \
-population $population \
-species $species \
-registry_file_oldasm  $pipeline_dir/ensembl.registry.oldasm \
-registry_file_oldasm_same_server $pipeline_dir/ensembl.registry.oldasm.same_server \
-registry_file_newasm $pipeline_dir/ensembl.registry.newasm \
-vcf_file $pipeline_dir/$vcf_file_name \
