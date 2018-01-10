password=$1
release=91
assembly=38
tmp_dir=/hps/nobackup/production/ensembl/anja/release_91/human/ancestral_alleles/
data_dir=/hps/nobackup/production/ensembl/anja/release_88/human/ancestral_alleles/
fasta_dir=$data_dir/data/homo_sapiens_ancestor_GRCh38_e86/
variation_api=$HOME/bin/ensembl-variation/scripts/import/
bsub -J AA_import_${release}_$asssembly -o ${tmp_dir}/AA_import_${release}_${assembly}.out -e ${tmp_dir}/AA_import_${release}_${assembly}.err \
-M5500 -R"select[mem>5500] rusage[mem=5500]" \
perl ${variation_api}/import_ancestral_alleles.pl \
-tmp_dir ${tmp_dir} \
-fasta_files_dir ${fasta_dir} \
-species human \
--mode update \
-version $release \
-host mysql-ens-var-prod-1.ebi.ac.uk \
-dbname homo_sapiens_variation_91_38 \
-user ensadmin \
-pass $password \
-port 4449 \
