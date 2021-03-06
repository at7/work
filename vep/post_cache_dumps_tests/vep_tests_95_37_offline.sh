perl $HOME/bin/ensembl-vep/vep \
--offline \
--assembly GRCh37 \
--dir /nfs/production/panda/ensembl/variation/data/VEP/ \
--input_file /hps/nobackup2/production/ensembl/anja/vep_data/input/grch37/cadd_test \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/grch37/cadd_test_offline.out \
--force_overwrite \
--cache \
--sift b --polyphen b --ccds --symbol --numbers --domains --regulatory --canonical --protein --biotype --uniprot --tsl --appris --gene_phenotype --af --af_1kg --af_esp --af_gnomad --max_af --pubmed --variant_class 
