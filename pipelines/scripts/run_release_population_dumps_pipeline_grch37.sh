ENS_VERSION=95
HIVE_SRV=mysql-ens-var-prod-2-ensadmin
BASE_DIR=${HOME}/bin
DUMP_DIR=/hps/nobackup2/production/ensembl/anja/release_95/human/grch37/dumps/population/
init_pipeline.pl Bio::EnsEMBL::Variation::Pipeline::ReleaseDataDumps::PopulationDumps_conf \
    $($HIVE_SRV details hive) \
    -ensembl_cvs_root_dir $BASE_DIR \
    -hive_root_dir ${BASE_DIR}/ensembl-hive \
    -registry_file ${DUMP_DIR}/ensembl.registry \
    -pipeline_dir $DUMP_DIR \
    -tmp_dir ${DUMP_DIR}/tmp_dir \
    -pipeline_name population_dumps_37_${ENS_VERSION} \
    -ensembl_release ${ENS_VERSION} \
    -hive_force_init 1 \
    -prefetched_frequencies /hps/nobackup2/production/ensembl/anja/allele_frequencies_37_95/  \
    -species homo_sapiens \
