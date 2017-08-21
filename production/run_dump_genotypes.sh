assembly=38
mode=correct_ychrom_genotypes
dir=/hps/nobackup/production/ensembl/anja/release_89/hapmap/$assembly/
if [ "$assembly" -eq "37" ]
then
  host=ensembldb.ensembl.org
  port=3337
  user=anonymous
else
  host=mysql-ens-var-prod-2.ebi.ac.uk
  user=ensro
  port=4521
fi
echo $host
perl /homes/anja/bin/ensembl-variation/scripts/export/dump_hapmap_genotypes.pl \
-mode $mode \
-dir $dir \
-registry $dir/ensembl.registry \
-species homo_sapiens \
#-host $host \
#-port $port \
#-user $user \
#-dbname homo_sapiens_variation_89_38 \
#-regsitry $dir/ensembl.registry \
#-frequency_dir $dir/allele_frequencies/ \
#-human_gvf_file $dir/Homo_sapiens.gvf  \
#-population_gvf_file $dir/HAPMAP.gvf  \
#-variation_ids_dir $dir/genotypes/ \
#  host=mysql-ensembl-mirror.ebi.ac.uk
#  port=4240
#  user=anonymous
