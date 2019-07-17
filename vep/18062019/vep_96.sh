data_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
vep_cache_dir=/nfs/production/panda/ensembl/variation/data/VEP/tabixconverted/
perl  $HOME/bin/ensembl-vep/vep \
--cache_version 96 \
--vcf \
--hgvs \
--offline \
--dir_cache $vep_cache_dir \
--format vcf \
--output_file $data_dir/output/grch37/congenica_test_grch37_96.out \
--input_file $data_dir/input/grch37/congenica_test_grch37.vcf.gz \
--no_progress --force_overwrite --no_stats \
--fasta /nfs/production/panda/ensembl/variation/data/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa \
--merged \
--all_refseq \
--assembly GRCh37 \
--fork 2 \
--force_overwrite \
--sift b --polyphen b --ccds --uniprot --hgvs --symbol --numbers --domains --canonical --protein --biotype --uniprot --tsl --appris --gene_phenotype --af --af_1kg --af_esp --af_gnomad --max_af --pubmed --variant_class \
