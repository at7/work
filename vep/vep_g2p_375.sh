vep_data=/hps/nobackup2/production/ensembl/anja/vep_data/
perl $HOME/bin/ensembl-vep/vep \
--cache_version 95 \
--assembly GRCh38 \
--dir /nfs/production/panda/ensembl/variation/data/VEP/tabixconverted/ \
--input_file ${vep_data}/input/grch38/NF_full.vcf \
--output_file ${vep_data}/output/NF_full.out \
--force_overwrite \
--cache \
--offline \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin G2P,file="${vep_data}/DDG2P_31_1_2019.csv" \
--symbol \
--biotype \
--numbers \
--total_length \
--canonical \
--gene_phenotype \
--ccds \
--uniprot \
--domains \
--regulatory \
--protein \
--tsl \
--appris \
--af \
--max_af \
--af_1kg \
--af_esp \
--af_gnomad \
--pubmed \
--variant_class \
--allele_number \
--fasta /hps/nobackup2/production/ensembl/anja/release_96/human/remap_gnomad/genomes/remapping/new_assembly/Homo_sapiens.GRCh38.dna.primary_assembly.fa \
--plugin SpliceRegion \
--sift b \
--polyphen b \
--hgvs \
--shift_hgvs 1 \
--species homo_sapiens \
--plugin MaxEntScan,/nfs/public/release/ensweb-data/latest/tools/grch37/e95/vep/plugin_data/maxentscan \
#--plugin LoF,human_ancestor_fa:false,loftee_path:/anaconda/share/ensembl-vep-95.1-0
#--plugin MaxEntScan,/anaconda/share/maxentscan-0_2004.04.21-1
#/vep --vcf -o stdout -i Research_trio_001-gatk-haplotype-joint-decompose.vcf.gz --fork 4 --species homo_sapiens --no_stats --cache --offline --dir genomes/Hsapiens/hg38/vep --symbol --numbers --biotype --total_length --canonical --gene_phenotype --ccds --uniprot --domains --regulatory --protein --tsl --appris --af --max_af --af_1kg --af_esp --af_gnomad --pubmed --variant_class --allele_number --fasta /genomes/Hsapiens/hg38/seq/hg38.fa.gz --plugin LoF,human_ancestor_fa:false,loftee_path:/anaconda/share/ensembl-vep-95.1-0 --plugin G2P,file:../variation/G2P.csv --plugin MaxEntScan,/anaconda/share/maxentscan-0_2004.04.21-1 --plugin SpliceRegion --sift b --polyphen b --hgvs --shift_hgvs 1 --merged | bgzip -c > Research_trio_001-gatk-haplotype-joint-decompose-vepeffects.vcf.gz

