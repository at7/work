ENS_VERSION=97
HIVE_SRV=mysql-ens-var-prod-1-ensadmin
init_pipeline.pl Bio::EnsEMBL::VEP::Pipeline::DumpVEP::DumpVEP_conf \
$($HIVE_SRV details hive)  \
-ensembl_release ${ENS_VERSION} \
-hive_root_dir /homes/anja/bin/ensembl-hive \
-registry /hps/nobackup2/production/ensembl/anja/release_97/human/vep_dumps/ensembl.registry \
-pipeline_name dump_vep_human_${ENS_VERSION} \
-pipeline_dir /hps/nobackup2/production/ensembl/anja/release_97/human/vep_dumps/ \
-species homo_sapiens \
-division vertebrates \
