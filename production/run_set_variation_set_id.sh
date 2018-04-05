registry=/hps/nobackup/production/ensembl/anja/release_92/human/ensembl.registry
species=human
bsub -J variation_set \
-o variation_set_human.out \
-e variation_set_human.err \
perl post_process_variation_feature_variation_set.pl \
-registry_file $registry \
-species $species  \
-clean \
