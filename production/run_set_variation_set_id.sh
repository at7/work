registry=/hps/nobackup2/production/ensembl/anja/release_98/opossum/ensembl.registry
species=opossum
bsub -J variation_set \
-o variation_set_opossum.out \
-e variation_set_opossum.err \
perl post_process_variation_feature_variation_set.pl \
-registry_file $registry \
-species $species  \
-clean \
