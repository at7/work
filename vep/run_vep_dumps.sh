ENS_VERSION=92
HIVE_SRV=mysql-ens-var-prod-2-ensadmin
init_pipeline.pl Bio::EnsEMBL::VEP::Pipeline::DumpVEP::DumpVEP_conf \
-ensembl_release ${ENS_VERSION} \
$($HIVE_SRV details hive)  \
-hive_root_dir /homes/anja/bin/ensembl-hive \
-registry /gpfs/nobackup/ensembl/anja/vep_dumps/vep_dumps_reg.pm \
-pipeline_name dump_vep_human_${ENS_VERSION} \
-pipeline_dir /gpfs/nobackup/ensembl/anja/vep_dumps/dump_vep_human_${ENS_VERSION} \
-species homo_sapiens
