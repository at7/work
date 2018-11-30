ENS_VERSION=95
HIVE_SRV=mysql-ens-var-prod-1-ensadmin
BASE_DIR=${HOME}/bin
DUMP_DIR=/hps/nobackup2/production/ensembl/anja/release_95/chicken/dumps/vertebrates/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::ReleaseDataDumps::ReleaseDumps_conf \
$($HIVE_SRV details hive) \
-ensembl_cvs_root_dir $BASE_DIR \
-hive_root_dir ${BASE_DIR}/ensembl-hive \
-registry ${DUMP_DIR}/ensembl.registry \
-pipeline_dir $DUMP_DIR \
-tmp_dir ${DUMP_DIR}/tmp_dir \
-pipeline_name dump_chicken_${ENS_VERSION} \
-ensembl_release ${ENS_VERSION} \
-hive_force_init 1
