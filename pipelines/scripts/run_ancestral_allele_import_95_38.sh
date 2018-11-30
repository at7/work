password=$1
release=95
assembly=38
tmp_dir=/hps/nobackup2/production/ensembl/anja/release_95/human/ancestral_alleles/
fasta_dir=/hps/nobackup2/production/ensembl/anja/release_94/ancestral_alleles_94/homo_sapiens_ancestor_GRCh38/
variation_api=$HOME/bin/ensembl-variation/scripts/import/
bsub -J AA_import_${release}_$asssembly -o ${tmp_dir}/AA_import_${release}_${assembly}.out -e ${tmp_dir}/AA_import_${release}_${assembly}.err \
-M15500 -R"select[mem>15500] rusage[mem=15500]" \
perl ${variation_api}/import_ancestral_alleles.pl \
-tmp_dir ${tmp_dir} \
-fasta_files_dir ${fasta_dir} \
-species human \
-mode update \
-version $release \
-host mysql-ens-var-prod-3.ebi.ac.uk \
-dbname homo_sapiens_variation_95_38 \
-user ensadmin \
-pass $password \
-port 4606 \
-source homo_sapiens_ancestor_GRCh38 \
