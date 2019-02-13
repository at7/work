password=$1
release=96
assembly=1
tmp_dir=/hps/nobackup2/production/ensembl/anja/release_96/orangutan/ancestral_alleles/
fasta_dir=$tmp_dir/pongo_abelii_ancestor_PPYG2/
variation_api=$HOME/bin/ensembl-variation/scripts/import/
bsub -J AA_import_${release}_$asssembly -o ${tmp_dir}/AA_import_${release}_${assembly}.out -e ${tmp_dir}/AA_import_${release}_${assembly}.err \
-M5500 -R"select[mem>5500] rusage[mem=5500]" \
perl ${variation_api}/import_ancestral_alleles.pl \
-tmp_dir ${tmp_dir} \
-fasta_files_dir ${fasta_dir} \
-species orangutan \
--mode load \
-version $release \
-host mysql-ens-var-prod-1.ebi.ac.uk \
-dbname pongo_abelii_variation_96_1 \
-user ensadmin \
-pass $password \
-port 4449 \
--source pongo_abelii_ancestor_PPYG2 \
--clean \
