perl  $HOME/bin/ensembl-vep/vep \
--species homo_sapiens \
--cache \
--offline \
--dir /hps/nobackup2/production/ensembl/anja/release_94/VEP/ \
--input_file  /hps/nobackup2/production/ensembl/anja/vep_data/input/regulatory_variant_location.txt \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/regulatory_variant_database_from_ftp.vcf \
--force_overwrite \
--regulatory \
--vcf --pick --gencode_basic --regulatory --variant_class --sift b --polyphen b --gene_phenotype --af_esp --af_1kg --af_gnomad \
--cache_version 94 \
#--dir /hps/nobackup2/production/ensembl/anja/release_94/vep_dumps/ \
#--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
