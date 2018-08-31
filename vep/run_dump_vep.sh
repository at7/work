ENS_VERSION=94
HIVE_SRV=mysql-ens-var-prod-1-ensadmin
init_pipeline.pl Bio::EnsEMBL::VEP::Pipeline::DumpVEP::DumpVEP_conf \
  -ensembl_release ${ENS_VERSION} \
  $($HIVE_SRV details hive)  \
  -registry /hps/nobackup2/production/ensembl/anja/release_94/ensembl_vep_cache_testdata/ensembl.registry \
