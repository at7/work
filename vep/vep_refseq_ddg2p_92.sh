perl $HOME/bin/ensembl-vep/vep \
--cache \
--cache_version 92 \
--dir /hps/nobackup2/production/ensembl/anja/vep/ \
--input_file /hps/nobackup2/production/ensembl/anja/vep_data/input/grch37/rachel_43_no_id_sorted.vcf.gz \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/04072018.txt \
--force_overwrite \
--assembly GRCh37 \
--port 3337 \
--cache \
--dir_plugins $HOME/bin/VEP_plugins \
--refseq \
--plugin G2P,file='/homes/anja/bin/work/vep/DDG2P_2_7_2018.csv',af_from_vcf=1 \
#--transcript_filter "gene_symbol in /homes/anja/bin/work/vep/genes_in_DDG2P.txt" \
#--plugin G2P,file='/homes/anja/bin/work/vep/DDG2P_12_6_2018.csv.gz',af_from_vcf=1 \
#--individual ALL \

