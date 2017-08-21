dir=/hps/nobackup/production/ensembl/anja/hapmap/38/
perl dump_genotypes.pl \
-mode dump_gvf \
-dir $dir \
-frequency_dir $dir/allele_frequencies/ \
-human_gvf_file $dir/Homo_sapiens.gvf  \
-population_gvf_file $dir/HAPMAP.gvf  \
-variation_ids_dir $dir/genotypes/ \
