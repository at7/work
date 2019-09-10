file=/hps/nobackup2/production/ensembl/anja/release_98/human/dumps/vertebrates/variation/homo_sapiens_generic-chr1.vcf
dd if=/dev/null of=$file bs=1 seek=$(echo $(stat --format=%s $file ) - $( tail -n1 $file | wc -c) | bc )
