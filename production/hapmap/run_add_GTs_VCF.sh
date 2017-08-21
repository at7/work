dir=/hps/nobackup/production/ensembl/anja/hapmap/38/
perl dump_hapmap_genotypes.pl \
-mode add_genotypes_to_vcf \
-assembly grch38 \
-in_vcf_file $dir/HAPMAP.vcf \
-out_vcf_file $dir/HAPMAP_GTS_20170105.vcf \
-genotype_cache_dir $dir/genotypes/ \
