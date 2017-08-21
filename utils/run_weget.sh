before="http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/supporting/GRCh38_positions/ALL.chr"
after="_GRCh38_sites.20170504.vcf.gz.tbi"

for i in {1..22}
do
  c=$before$i$after
  echo $c
  bsub -J wget$i -o ${i}.out -e ${i}.err wget $c
done
