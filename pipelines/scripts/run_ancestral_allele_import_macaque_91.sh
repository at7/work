password=$1
release=91
assembly=801
tmp_dir=/hps/nobackup/production/ensembl/anja/release_91/macaque/ancestral_alleles/
fasta_dir=/hps/nobackup/production/ensembl/anja/ancestral_alleles/macaca_mulatta_ancestor_Mmul_8.0.1/
variation_api=$HOME/bin/ensembl-variation/scripts/import/
bsub -J AA_import_${release}_$asssembly -o ${tmp_dir}/AA_import_${release}_${assembly}.out -e ${tmp_dir}/AA_import_${release}_${assembly}.err \
-M5500 -R"select[mem>5500] rusage[mem=5500]" \
perl ${variation_api}/import_ancestral_alleles.pl \
-tmp_dir ${tmp_dir} \
-fasta_files_dir ${fasta_dir} \
-species macaque \
--mode load \
-version $release \
-host mysql-ens-var-prod-1.ebi.ac.uk \
-dbname macaca_mulatta_variation_91_801 \
-user ensadmin \
-pass $password \
-port 4449 \
