for chr in {1..22} 'X' 'Y'
do
  i_37=`bcftools index --nrecords /nfs/production/panda/ensembl/variation/data/gnomAD/v2.1/grch37/exomes/gnomad.exomes.r2.1.sites.chr${chr}_noVEP.vcf.gz`
  i_unmap=`bcftools index --nrecords /hps/nobackup2/production/ensembl/anja/gnomad/Exomes/mapping_results/unmapped/gnomad.exomes.r2.1.sites.grch38.chr${chr}_noVEP.vcf.unmap.gz`
  i_crossmap=$((i_37-i_unmap))
  i_ensembl_unique_map=`wc -l < /hps/nobackup2/production/ensembl/anja/release_96/human/remap_gnomad/exomes/unique_mappings/chrom${chr}.txt`
  i_successfully_mapped=$((i_crossmap+i_ensembl_unique_map))
  i_end_file=`bcftools index --nrecords /nfs/production/panda/ensembl/variation/data/gnomAD/v2.1/grch38/exomes/gnomad.exomes.r2.1.sites.grch38.chr${chr}_noVEP.vcf.gz`
  i_qc_add=$((i_crossmap+i_unmap))
  i_gnomad_unmapped=$((i_unmap-i_ensembl_unique_map))
  i_final_count=$((i_end_file+i_gnomad_unmapped))
  echo $chr $i_end_file $i_gnomad_unmapped $i_37
done
# 37_records 38_records_after_crossmap 38_records_after_ensembl_mapping_pipeline
# 37_records 38_crossmap 38_crossmap_unmapped
#  echo $chr $i_unmap $i_ensembl_unique_map $i_gnomad_unmapped $percent_failed

#/hps/nobackup2/production/ensembl/anja/release_96/human/remap_gnomad/exomes/unique_mappings
#  i_38=`bcftools index --nrecords /nfs/production/panda/ensembl/variation/data/gnomAD/v2.1/grch38/exomes/gnomad.exomes.r2.1.sites.grch38.chr${chr}_noVEP.vcf.gz`
#  i_diff=$((i_37-i_38))
#  i_unmap=`bcftools index --nrecords /hps/nobackup2/production/ensembl/anja/gnomad/Exomes/mapping_results/unmapped/gnomad.exomes.r2.1.sites.grch38.chr${chr}_noVEP.vcf.unmap.gz`
#  echo $chr $i_37 $i_crossmap $i_unmap $i_ensembl_unique_map $i_successfully_mapped $i_end_file 
#  echo $chr $i_37 $i_crossmap $i_unmap $i_qc_add 


