script_dir=/homes/anja/bin/ensembl-variation/scripts/import/
working_dir=/hps/nobackup/production/ensembl/anja/release_90/human/projections/
bsub -q production-rh7 -M 10000 -R "rusage[mem=10000]" -J projections -o ${working_dir}projections.out -e ${working_dir}projections.err \
perl ${script_dir}project_feature.pl \
-oldasm_name GRCh38 \
-newasm_name GRCh37 \
-working_dir ${working_dir} \
-load_failed_projections \
-feature_type vf \
-feature_table_name_oldasm variation_feature_topmed_38 \
-feature_table_name_newasm variation_feature_topmed_37 \
-load_failed_projections \
-vdbname_newasm homo_sapiens_variation_90_37_seh \
-vhost_newasm mysql-ens-var-prod-1.ebi.ac.uk \
-vuser_newasm ensadmin \
-p \
-vport_newasm 4449 \
-cdbname_oldasm homo_sapiens_core_89_38 \
-chost_oldasm mysql-ensembl-mirror.ebi.ac.uk \
-cuser_oldasm anonymous \
-cport_oldasm 4240 \
-cdbname_newasm homo_sapiens_core_89_37 \
-chost_newasm ensembldb.ensembl.org \
-cuser_newasm anonymous \
-cport_newasm 3337 \
