dir=/hps/nobackup/production/ensembl/anja/hapmap/38/
perl /homes/anja/bin/ensembl-variation/scripts/misc/release/gvf2vcf.pl \
-gvf_file $dir/HAPMAP.gvf \
-vcf_file $dir/HAPMAP.vcf \
-species homo_sapiens \
-registry $dir/registry \
