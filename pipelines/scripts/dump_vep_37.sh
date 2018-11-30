ENS_VERSION=95
HIVE_SRV=mysql-ens-var-prod-2-ensadmin
init_pipeline.pl Bio::EnsEMBL::VEP::Pipeline::DumpVEP::DumpVEP_conf \
$($HIVE_SRV details hive)  \
-ensembl_release ${ENS_VERSION} \
-hive_root_dir /homes/anja/bin/ensembl-hive \
-registry /hps/nobackup2/production/ensembl/anja/release_95/human/grch37/vep_dumps/ensembl.registry \
-pipeline_name dump_vep_human_37_${ENS_VERSION} \
-pipeline_dir /hps/nobackup2/production/ensembl/anja/release_95/human/grch37/vep_dumps/ \
-species homo_sapiens
