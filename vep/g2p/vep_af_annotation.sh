vep_data=/hps/nobackup2/production/ensembl/anja/G2P/test_data/
perl $HOME/bin/ensembl-vep/vep \
--cache --cache_version 90 \
--assembly GRCh37 \
--offline \
--dir /hps/nobackup2/production/ensembl/anja/vep/ \
--input_file ${vep_data}/suspect_gnomad_grch37.vcf.gz \
--output_file ${vep_data}/suspect_gnomad_grch37_90_out.vcf \
--force_overwrite \
--af_1kg \
--af_gnomad \
--af_esp \
--canonical \
--vcf \
--fork 4 \
