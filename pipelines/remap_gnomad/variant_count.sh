for chr in {1..22} 'X' 'Y'
do
  i_37=`bcftools index --nrecords /nfs/production/panda/ensembl/variation/data/gnomAD/v2.1/grch37/exomes/gnomad.exomes.r2.1.sites.chr${chr}_noVEP.vcf.gz`
  i_38=`bcftools index --nrecords /hps/nobackup2/production/ensembl/anja/gnomad/Exomes/mapping_results/gnomad.exomes.r2.1.sites.grch38.chr${chr}_noVEP.vcf.gz`
  i_diff=$((i_37-i_38))
  i_unmap=`bcftools index --nrecords /hps/nobackup2/production/ensembl/anja/gnomad/Exomes/mapping_results/gnomad.exomes.r2.1.sites.grch38.chr${chr}_noVEP.vcf.unmap.gz`
  echo $chr  $i_37 $i_38 $i_diff $i_unmap 
done
