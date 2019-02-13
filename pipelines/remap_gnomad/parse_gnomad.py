from cmmodule import ireader
infile = '/hps/nobackup2/production/ensembl/anja/gnomad/Exomes/gnomad.exomes.r2.1.sites.chr5.vcf.bgz'

for line in ireader.reader(infile):
  if not line.strip():
    continue
  line=line.strip()
