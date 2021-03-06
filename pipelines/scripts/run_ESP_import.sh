tmpdir=/gpfs/nobackup/ensembl/anja/release_98/human/ESP/
version=98
assembly=38
bsub -J import_ESP_$version -o $tmpdir/import_ESP_set.out -e $tmpdir/import_ESP_set.err -R"select[mem>5000] rusage[mem=5000]" -M5000 perl $HOME/bin/ensembl-variation/scripts/import/import_ESP.pl \
-tmp_dir $tmpdir/ \
-vcf_files_dir /gpfs/nobackup/ensembl/anja/release_98/human/ESP/data/ \
-registry $tmpdir/ensembl.registry \
-assembly $assembly \
-release_version $version \
-esp_version 20141103 \
-create_set 1 \
