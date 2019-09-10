data_dir=/hps/nobackup2/production/ensembl/anja/release_98/human/dumps/vertebrates/variation/
bsub -q production-rh74 -R"select[mem>1250] rusage[mem=1250]" -M1250 -J gvf2vcf_chr1 -e ${data_dir}/chr1.err -o ${data_dir}/chr1.out \
perl /homes/anja/bin/ensembl-variation/scripts/misc/release/gvf2vcf.pl \
--evidence --ancestral_allele --clinical_significance --global_maf --variation_id --allele_string \
--registry $data_dir/ensembl.registry \
--gvf_file $data_dir/homo_sapiens_generic-chr1.gvf \
--vcf_file $data_dir/homo_sapiens_generic-chr1_rest.vcf \
--species homo_sapiens \
