password=$1
release=91
assembly=3
tmp_dir=/hps/nobackup/production/ensembl/anja/release_91/gibbon/ancestral_alleles/
fasta_dir=/hps/nobackup/production/ensembl/anja/ancestral_alleles/nomascus_leucogenys_ancestor_Nleu_3.0/
variation_api=$HOME/bin/ensembl-variation/scripts/import/
bsub -J AA_import_${release}_$asssembly -o ${tmp_dir}/AA_import_${release}_${assembly}.out -e ${tmp_dir}/AA_import_${release}_${assembly}.err \
-M5500 -R"select[mem>5500] rusage[mem=5500]" \
perl ${variation_api}/import_ancestral_alleles.pl \
-tmp_dir ${tmp_dir} \
-fasta_files_dir ${fasta_dir} \
-species gibbon \
--mode load \
-version $release \
-host mysql-ens-var-prod-2.ebi.ac.uk \
-dbname nomascus_leucogenys_variation_91_3 \
-user ensadmin \
-pass $password \
-port 4521 \
