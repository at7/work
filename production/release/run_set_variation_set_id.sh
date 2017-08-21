registry=$1
species=$2
script_dir=/homes/anja/bin/ensembl-variation/scripts/import/
echo $registry
cd $script_dir
bsub -J variation_set \
-o variation_set.out \
-e variation_set.err \
perl post_process_variation_feature_variation_set.pl \
-registry_file $registry \
-species $species  \
-clean \
