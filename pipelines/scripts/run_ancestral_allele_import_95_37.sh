password=$1
release=95
assembly=37
tmp_dir=/hps/nobackup2/production/ensembl/anja/release_95/human/grch37/ancestral_alleles/
fasta_dir=/hps/nobackup2/production/ensembl/anja/release_88/human/ancestral_alleles/data/homo_sapiens_ancestor_GRCh37_e71/
variation_api=$HOME/bin/ensembl-variation/scripts/import/
bsub -J AA_import_${release}_$asssembly -o ${tmp_dir}/resume_AA_import_${release}_${assembly}.out -e ${tmp_dir}/resume_AA_import_${release}_${assembly}.err \
-M5500 -R"select[mem>5500] rusage[mem=5500]" \
perl ${variation_api}/import_ancestral_alleles.pl \
-tmp_dir ${tmp_dir} \
-fasta_files_dir ${fasta_dir} \
-species human \
--mode load \
-version $release \
-host mysql-ens-var-prod-1.ebi.ac.uk \
-dbname homo_sapiens_variation_95_37 \
-user ensadmin \
-pass $password \
-port 4449 \
-source homo_sapiens_ancestor_GRCh37_e71 \
