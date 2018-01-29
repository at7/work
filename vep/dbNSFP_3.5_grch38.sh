working_dir=/hps/nobackup/production/ensembl/anja/
bsub -q production-rh7 -M 5000 -R "rusage[mem=5000]" -J vep -o $working_dir/vep_data/dbnsfp_3.5a_grch38.out -e $working_dir/vep_data/dbnsfp_3.5a_grch38.err \
perl $HOME/bin/ensembl-vep/vep \
-i $working_dir/vep_data/input/clinvar_grch38.txt \
-o $working_dir/vep_data/output/dbnsfp_3.5a_grch38.txt \
--cache \
--dir_cache /hps/nobackup/production/ensembl/anja/vep/ \
--dir_plugins /homes/anja/bin/VEP_plugins/ \
--plugin dbNSFP,/nfs/production/panda/ensembl/variation/data/dbNSFP/3.5a/dbNSFP3.5a.txt.gz,MetaSVM_pred,GERP++_RS,LRT_pred,MutationTaster_pred,MutationAssessor_pred,FATHMM_pred,PROVEAN_pred,M-CAP_pred,Interpro_domain \
--force_overwrite \
#perl -I /root/.vep/Plugins/ /opt/ensembl-vep/vep --offline --dir /opt/ensembl-vep --input_file test.vcf --fasta Homo_sapiens_assembly38.tab.fasta.gz --fork 8 --buffer_size 20000 --custom dbSNP_150_All_20170710.vcf.gz,rs_dbSNP150,vcf --custom repeats_hg38.bed.gz,RepeatFlag,bed --output_file test.vep.vcf --no_stats --variant_class --sift b --polyphen b --domains -no_escape --keep_csq --terms SO --numbers --total_length --regulatory --xref_refseq --hgvs --hgvsg --protein --symbol --uniprot --canonical --biotype --shift_hgvs 1 --check_existing --pubmed --af --af_1kg --af_esp --af_gnomad --max_af --vcf --format vcf --plugin LoFtool --plugin MaxEntScan,/opt/ensembl-vep/plugin-files --plugin CSN --plugin dbNSFP,dbNSFP_3.5c.gz,MetaSVM_pred,GERP++_RS,LRT_pred,MutationTaster_pred,MutationAssessor_pred,FATHMM_pred,PROVEAN_pred,M-CAP_pred,Interpro_domain --plugin dbscSNV,dbscSNV.txt.gz```
