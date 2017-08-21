assembly=38
mode=dump_gvf
dir=/hps/nobackup/production/ensembl/anja/hapmap/$assembly/
if [ "$assembly" -eq "37" ]
then
  host=ensembldb.ensembl.org
  port=3337
  user=anonymous
else
  host=mysql-ensembl-mirror.ebi.ac.uk
  port=4240
  user=anonymous
fi

perl tests_dump_hapmap_genotypes.pl  \
-dir $dir \
-host $host \
-port $port \
-user $user \
