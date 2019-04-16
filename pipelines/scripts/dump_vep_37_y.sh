ENS_VERSION=96
HIVE_SRV=mysql-ens-var-prod-3-ensadmin
init_pipeline.pl Bio::EnsEMBL::VEP::Pipeline::DumpVEP::DumpVEP_conf \
$($HIVE_SRV details hive)  \
-ensembl_release ${ENS_VERSION} \
-hive_root_dir /homes/anja/bin/ensembl-hive \
-registry /hps/nobackup2/production/ensembl/anja/release_96/human/GRCh37/vep_dumps_y/ensembl.registry \
-pipeline_name dump_vep_human_37_y_${ENS_VERSION} \
-pipeline_dir /hps/nobackup2/production/ensembl/anja/release_96/human/GRCh37/vep_dumps_y/ \
-species homo_sapiens \
-division vertebrates \
