registry=/hps/nobackup2/production/ensembl/anja/release_96/cow/remapping/ensembl.registry.newasm
species=cow
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
