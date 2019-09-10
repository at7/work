data_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
vep_cache_dir=/nfs/production/panda/ensembl/variation/data/VEP/
perl  $HOME/bin/ensembl-vep/vep \
--dir_cache $vep_cache_dir \
--offline --cache --cache_version 97 \
--assembly GRCh38 \
--input_file $data_dir/input/grch38/gnomad_refseq.vcf \
--output_file $data_dir/output/grch38/gnomad_refseq.out \
--verbose \
--force_overwrite \
--force \
--no_stats \
--fasta /nfs/production/panda/ensembl/variation/data/Homo_sapiens.GRCh38.dna.toplevel.fa.gz \
--refseq --use_given_ref --vcf --allele_number --numbers --no_escape --af --max_af --af_1kg --af_gnomad --failed 1 \
--custom /hps/nobackup2/production/ensembl/anja/gnomad.exomes.r2.1.1.sites.liftover_grch38.vcf.bgz,gnomAD_custom,vcf,exact,0,AF,AF_eas,AF_oth,AF_popmax,popmax \
#--plugin dbNSFP,/nfs/production/panda/ensembl/variation/data/dbNSFP/4.0a/dbNSFP4.0a_grch37.gz,ALL \
#--dir_plugins /homes/anja/bin/VEP_plugins/ \
#--refseq --use_given_ref --vcf --allele_number --numbers --no_escape --af --max_af --af_1kg --af_gnomad --failed 1 \

