registry=$1
species=$2
script_dir=/nfs/users/nfs_a/at7/DEV/ensembl-variation/scripts/import/
cd script_dir
bsub -J variation_set \
-o variation_set_svs.out \
-e variation_set_svs.err \
perl post_process_variation_feature_variation_set.pl \
-registry_file $registry \
-species $species  \
-clean \
-sv 1 \
