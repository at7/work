tmpdir=/gpfs/nobackup/ensembl/anja/release_98/human/ESP/
version=98
assembly=38
bsub -J import_ESP_$version -o $tmpdir/import_ESP_debug2.out -e $tmpdir/import_ESP_debug2.err -R"select[mem>5000] rusage[mem=5000]" -M5000 perl $HOME/bin/ensembl-variation/scripts/import/import_ESP.pl \
-tmp_dir $tmpdir/ \
-vcf_files_dir /gpfs/nobackup/ensembl/anja/release_98/human/ESP/test_data/ \
-registry $tmpdir/ensembl.registry \
-assembly $assembly \
-release_version $version \
-esp_version 20141103 \
