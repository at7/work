working_dir=/hps/nobackup2/production/ensembl/anja/
bsub -q production-rh7 -M 5000 -R "rusage[mem=5000]" -J vep -o $working_dir/vep_data/dbnsfp_3.5_grch37.out -e $working_dir/vep_data/dbnsfp_3.5_grch37.err \
perl $HOME/bin/ensembl-vep/vep \
-i $working_dir/vep_data/input/grch37/rs45575235.txt  \
-o $working_dir/vep_data/output/dbnsfp_3.5_grch37_15_08_2018.txt \
--dir_cache /hps/nobackup2/production/ensembl/anja/vep/ \
--cache_version 93 \
--dir_plugins /homes/anja/bin/VEP_plugins/ \
--cache \
-sift b \
--polyphen b \
--symbol \
--numbers \
--biotype \
--total_length \
--vcf \
--fields Consequence,Codons,Amino_acids,Gene,SYMBOL,Feature,EXON,PolyPhen,SIFT,Protein_position,BIOTYPE \
--port 3337 \
--plugin dbNSFP,/nfs/production/panda/ensembl/variation/data/dbNSFP/3.5a_grch37/dbNSFP3.5a_grch37.txt.gz,SIFT_score,SIFT_converted_rankscore,SIFT_pred,Uniprot_acc_Polyphen2,Uniprot_id_Polyphen2,Uniprot_aapos_Polyphen2,Polyphen2_HDIV_score,Polyphen2_HDIV_rankscore,Polyphen2_HDIV_pred,Polyphen2_HVAR_score,Polyphen2_HVAR_rankscore,Polyphen2_HVAR_pred,LRT_score,LRT_converted_rankscore,LRT_pred,LRT_Omega,MutationTaster_score,MutationTaster_converted_rankscore,MutationTaster_pred,MutationTaster_model,MutationTaster_AAE,MutationAssessor_UniprotID,MutationAssessor_variant,MutationAssessor_score,MutationAssessor_score_rankscore,MutationAssessor_pred,FATHMM_score,FATHMM_converted_rankscore,FATHMM_pred,PROVEAN_score,PROVEAN_converted_rankscore,PROVEAN_pred,Transcript_id_VEST3,Transcript_var_VEST3,VEST3_score,VEST3_rankscore,MetaSVM_score,MetaSVM_rankscore,MetaSVM_pred,MetaLR_score,MetaLR_rankscore,MetaLR_pred,Reliability_index,M-CAP_score,M-CAP_rankscore,M-CAP_pred,REVEL_score,REVEL_rankscore,MutPred_score,MutPred_rankscore,MutPred_protID,MutPred_AAchange,MutPred_Top5features,CADD_raw,CADD_raw_rankscore,CADD_phred,DANN_score,DANN_rankscore,fathmm-MKL_coding_score \
--force_overwrite
