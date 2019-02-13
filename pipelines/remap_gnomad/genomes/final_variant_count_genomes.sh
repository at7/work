dir=/nfs/production/panda/ensembl/variation/data/gnomAD/v2.1/
for chr in {1..22} 'X'
do
  i_37=`bcftools index --nrecords $dir/grch37/genomes/gnomad.genomes.r2.1.sites.chr${chr}_noVEP.vcf.gz`
  i_unmap=`bcftools index --nrecords /hps/nobackup2/production/ensembl/anja/gnomad/Genomes/mapping_results/unmapped/gnomad.genomes.r2.1.sites.grch38.chr${chr}_noVEP.vcf.unmap.gz`
  i_crossmap=$((i_37-i_unmap))
  i_crossmap_mapped=`bcftools index --nrecords /hps/nobackup2/production/ensembl/anja/gnomad/Genomes/mapping_results/unmapped/gnomad.genomes.r2.1.sites.grch38.chr${chr}_noVEP.vcf.gz`
  i_ensembl_unique_map=`wc -l < /hps/nobackup2/production/ensembl/anja/release_96/human/remap_gnomad/genomes/unique_mappings/chrom${chr}.txt`
  i_successfully_mapped=$((i_crossmap+i_ensembl_unique_map))
  i_end_file=`bcftools index --nrecords $dir/grch38/genomes/gnomad.genomes.r2.1.sites.grch38.chr${chr}_noVEP.vcf.gz`
  i_qc_add=$((i_crossmap+i_unmap))
  i_gnomad_unmapped=$((i_unmap-i_ensembl_unique_map))
  i_final_count=$((i_end_file+i_gnomad_unmapped))
  echo $chr $i_37 $i_crossmap $i_crossmap_mapped
done


# chr 38_gnomad_records unmapped_gnomad_records 37_gnomad_records


# chr 38_crossmap_unmapped 38_ensembl_mapped 38_final_unmapped_records(=38_crossmap_unmapped-38_ensembl_mapped)
  #echo $chr $i_unmap $i_ensembl_unique_map $i_gnomad_unmapped




#  echo $chr $i_end_file $i_gnomad_unmapped $i_37
#chr 37_records 38_crossmap 38_crossmap_unmapped 38_crossmap+38_crossmap_unmapped
#$chr $i_37 $i_crossmap $i_unmap $i_37

# 37_records 38_records_after_crossmap 38_records_after_ensembl_mapping_pipeline
# 37_records 38_crossmap 38_crossmap_unmapped
#  echo $chr $i_unmap $i_ensembl_unique_map $i_gnomad_unmapped $percent_failed
#  echo $chr $i_end_file $i_gnomad_unmapped $i_37


#/hps/nobackup2/production/ensembl/anja/release_96/human/remap_gnomad/exomes/unique_mappings
#  i_38=`bcftools index --nrecords /nfs/production/panda/ensembl/variation/data/gnomAD/v2.1/grch38/exomes/gnomad.exomes.r2.1.sites.grch38.chr${chr}_noVEP.vcf.gz`
#  i_diff=$((i_37-i_38))
#  i_unmap=`bcftools index --nrecords /hps/nobackup2/production/ensembl/anja/gnomad/Exomes/mapping_results/unmapped/gnomad.exomes.r2.1.sites.grch38.chr${chr}_noVEP.vcf.unmap.gz`
#  echo $chr $i_37 $i_crossmap $i_unmap $i_ensembl_unique_map $i_successfully_mapped $i_end_file 
#  echo $chr $i_37 $i_crossmap $i_unmap $i_qc_add 


