password=$1
release=96
assembly=38
tmp_dir=/hps/nobackup2/production/ensembl/anja/release_96/human/ancestral_alleles/
fasta_dir=$tmp_dir/homo_sapiens_ancestor_GRCh38/
variation_api=$HOME/bin/ensembl-variation/scripts/import/
bsub -J AA_import_${release}_$asssembly -o ${tmp_dir}/AA_import_${release}_${assembly}.out -e ${tmp_dir}/AA_import_${release}_${assembly}.err \
-M1500 -R"select[mem>1500] rusage[mem=1500]" \
perl ${variation_api}/import_ancestral_alleles.pl \
-tmp_dir ${tmp_dir} \
-fasta_files_dir ${fasta_dir} \
-species human \
-mode load \
-version $release \
-host mysql-ens-var-prod-3.ebi.ac.uk \
-dbname homo_sapiens_variation_96_38 \
-user ensadmin \
-pass $password \
-port 4606 \
-source homo_sapiens_ancestor_GRCh38 \
--clean \
