ENS_VERSION=90
HIVE_SRV=mysql-ens-var-prod-1-ensadmin
BASE_DIR=${USER}/bin
DUMP_DIR=/hps/nobackup/production/ensembl/anja/release_90/dumps/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::ReleaseDataDumps::ReleaseDumps_conf \
$($HIVE_SRV details hive) \
-ensembl_cvs_root_dir $BASE_DIR \
-hive_root_dir ${BASE_DIR}/ensembl-hive \
-registry ensembl.registry \
-pipeline_dir $DUMP_DIR \
-tmp_dir ${DUMP_DIR}/tmp_dir \
-pipeline_name dumps_${ENS_VERSION} \
-ensembl_release ${ENS_VERSION} \
-run_all 1 \
-hive_force_init 1
