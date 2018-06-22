registry=/hps/nobackup2/production/ensembl/anja/release_93/cat/ensembl.registry
species=cat
bsub -J variation_set \
-o variation_set_cat.out \
-e variation_set_cat.err \
perl post_process_variation_feature_variation_set.pl \
-registry_file $registry \
-species $species  \
-clean \
