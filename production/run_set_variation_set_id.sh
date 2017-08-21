registry=/hps/nobackup/production/ensembl/anja/release_90/pig/ensembl.registry
species=pig
bsub -J variation_set \
-o variation_set.out \
-e variation_set.err \
perl post_process_variation_feature_variation_set.pl \
-registry_file $registry \
-species $species  \
-clean \
