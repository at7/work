password=$1
release=91
assembly=1
tmp_dir=/hps/nobackup/production/ensembl/anja/release_91/orangutan/ancestral_alleles/
fasta_dir=/hps/nobackup/production/ensembl/anja/ancestral_alleles/pongo_abelii_ancestor_PPYG2/
variation_api=$HOME/bin/ensembl-variation/scripts/import/
bsub -J AA_import_${release}_$asssembly -o ${tmp_dir}/AA_import_${release}_${assembly}.out -e ${tmp_dir}/AA_import_${release}_${assembly}.err \
-M5500 -R"select[mem>5500] rusage[mem=5500]" \
perl ${variation_api}/import_ancestral_alleles.pl \
-tmp_dir ${tmp_dir} \
-fasta_files_dir ${fasta_dir} \
-species orangutan \
--mode load \
-version $release \
-host mysql-ens-var-prod-2.ebi.ac.uk \
-dbname pongo_abelii_variation_91_1 \
-user ensadmin \
-pass $password \
-port 4521 \
