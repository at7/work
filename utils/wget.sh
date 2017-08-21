for i in {1..22} 'X' 'Y';do
  wget 'http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/supporting/GRCh38_positions/ALL.chr'$i'_GRCh38.genotypes.20170504.vcf.gz.tbi'
done
