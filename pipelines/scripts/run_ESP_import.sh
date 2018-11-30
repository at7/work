tmpdir=/hps/nobackup2/production/ensembl/anja/release_95/human/grch37/ESP/
version=95
assembly=37
bsub -J import_ESP_$version -o $tmpdir/import_ESP.out -e $tmpdir/import_ESP.err -R"select[mem>5000] rusage[mem=5000]" -M5000 perl $HOME/bin/ensembl-variation/scripts/import/import_ESP.pl \
-tmp_dir $tmpdir/ \
-vcf_files_dir /hps/nobackup2/production/ensembl/anja/release_88/human/ESP/data/ \
-registry $tmpdir/ensembl.registry \
-assembly $assembly \
-release_version $version \
-esp_version 20141103 \
-assign_evidence 1 \
-create_set 1 \
