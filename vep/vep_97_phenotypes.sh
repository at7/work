data_dir=/hps/nobackup2/production/ensembl/anja/vep_data/
vep_cache_dir=/nfs/production/panda/ensembl/variation/data/VEP/tabixconverted/
SIRA=Uploaded_variation,PHENOTYPES
PHENO=/homes/anja/bin/VEP_plugins/Phenotypes.pm_homo_sapiens_97_GRCh37.gvf.gz
perl  $HOME/bin/ensembl-vep/vep \
--fork 1 \
--refseq \
--use_given_ref \
--force_overwrite \
--coding_only \
--format vcf \
--input_file $data_dir/input/grch37/small_example_phenotypes.vcf \
--output_file $data_dir/output/grch37/toy_example_phenotype.out \
--dir_cache $vep_cache_dir \
--offline \
--cache_version 97 \
--cache \
--assembly GRCh37 \
--tab \
--check_existing \
--biotype \
--canonical \
--domains \
--uniprot \
--ccds \
--symbol \
--protein \
--hgvs \
--no_escape \
--numbers \
--show_ref_allele \
--allele_number \
--humdiv \
--polyphen p \
--sift p \
--variant_class \
--individual all \
--fasta /nfs/production/panda/ensembl/variation/data/Homo_sapiens.GRCh37.dna.primary_assembly.fa.gz \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin Phenotypes,file=$PHENO,include_types=Gene \
#--plugin dbNSFP,/nfs/production/panda/ensembl/variation/data/dbNSFP/3.5a_grch37/dbNSFP3.5a_grch37.txt.gz,ALL \
#--plugin Mastermind,'/nfs/production/panda/ensembl/variation/data/MasterMind/grch37/mastermind_cited_variants_reference-2019.06.14-grch37.vcf.gz' \
#--plugin G2P,file="/hps/nobackup2/production/ensembl/anja/vep_data/DDG2P_31_1_2019.csv" \
#--custom /hps/nobackup2/production/ensembl/anja/vep_data/clinvar_20190902.vcf.gz,ClinVar,vcf,exact,0,CLNSIG,CLNREVSTAT,CLNDN \
#--plugin Phenotypes,file=$PHENO,include_types=Gene \
#--fields=$SIRA
#--plugin Condel,/homes/anja/bin/VEP_plugins/config/Condel/config/condel_SP.conf,p \
#--plugin Phenotypes,file=/homes/anja/bin/VEP_plugins/Phenotypes.pm_homo_sapiens_97_GRCh37.gvf.gz,include_types=Gene \
#--plugin dbNSFP,/nfs/production/panda/ensembl/variation/data/dbNSFP/3.5a_grch37/dbNSFP3.5a_grch37.txt.gz,ALL \
#--plugin dbNSFP,$VEPDATA/dbNSFP3.5/dbNSFP3.5.gz,ALL \
#--plugin Condel,$CACHE/Plugins/config/Condel/config/condel_SP.conf,p \
#--plugin Mastermind,$VEPDATA/mastermind/mastermind_cited_variants_reference-2019.06.14-grch37.vcf.gz \
#--plugin G2P,file="$VEPDATA/G2P/DDG2P_10_7_2019.csv",log_dir="$LOGDIR/$FILE",txt_report="$LOGDIR/$FILE/$BASE.txt",html_report="$LOGDIR/$FILE/$BASE.html" \
#--custom $VEPDATA/clinvar/clinvar_20190513.vcf.gz,ClinVar,vcf,exact,0,CLNSIG,CLNREVSTAT,CLNDN \
