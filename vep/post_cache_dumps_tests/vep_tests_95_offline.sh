perl $HOME/bin/ensembl-vep/vep \
--offline \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file /hps/nobackup2/production/ensembl/anja/vep_data/input/grch38/homo_sapiens-chr14.vcf.gz \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/grch38/homo_sapiens-chr14_offline.out \
--force_overwrite \
--cache \
--sift b --polyphen b --ccds --symbol --numbers --domains --regulatory --canonical --protein --biotype --uniprot --tsl --appris --gene_phenotype --af --af_1kg --af_esp --af_gnomad --max_af --pubmed --variant_class 
