working_dir=/hps/nobackup2/production/ensembl/anja/release_94/human/grch37/dumps/
bsub -q production-rh7 -M 5000 -R "rusage[mem=5000]" -J gvf -o ${working_dir}gvf.out -e ${working_dir}gvf.err \
perl  /homes/anja/bin/ensembl-variation/scripts//export/release/dump_gvf.pl \
--sift --polyphen --incl_consequences --protein_coding_details --evidence --ancestral_allele --clinical_significance --global_maf \
--species homo_sapiens \
--is_slice_piece \
--seq_region_id 27517 \
--slice_piece_end 198022430  \
--seq_region_name 3 \
--slice_piece_start 193071880  \
--gvf_file $working_dir/homo_sapiens_incl_consequences-27517_193071880_198022430.gvf \
--registry $working_dir/ensembl.registry \
