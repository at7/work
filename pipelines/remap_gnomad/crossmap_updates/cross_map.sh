working_dir=/hps/nobackup2/production/ensembl/anja/gnomad/
/homes/anja/bin/CrossMap-0.2.8/bin/CrossMap.py vcf \
$working_dir/GRCh37_to_GRCh38.chain.gz \
/nfs/production/panda/ensembl/variation/data/gnomAD/v2.1/grch37/genomes/gnomad.genomes.r2.1.sites.chr18_noVEP.vcf.gz \
$working_dir/fasta/Homo_sapiens.GRCh38.dna.primary_assembly.fa \
$working_dir/crossmap_updates/gnomad_genomes_chr18.vcf \
