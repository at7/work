script_dir=/nfs/users/nfs_a/at7/DEV/ensembl-variation/scripts/import/
working_dir=/lustre/scratch110/ensembl/at7/release_80/rat/projections/
bsub -J projections_rat -o ${working_dir}projections.out -e ${working_dir}projections.err \
perl ${script_dir}project_feature.pl \
-oldasm_name Rnor_5.0 \
-newasm_name Rnor_6.0 \
-working_dir ${working_dir} \
-load_failed_projections \
-feature_type vf \
-feature_table_name_oldasm variation_feature \
-feature_table_name_newasm variation_feature_6 \
-load_failed_projections \
-vdbname_newasm rattus_norvegicus_variation_80_6 \
-vhost_newasm genebuild10 \
-p ensembl \
-cdbname_oldasm rattus_norvegicus_core_79_5 \
-chost_oldasm ens-livemirror \
-cdbname_newasm rattus_norvegicus_core_80_6 \
-chost_newasm ens-staging2 \
