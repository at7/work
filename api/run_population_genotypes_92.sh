species=sheep
#population=NextGen:MOCH
#population=ISGC:ROMNEY
population=NextGen:IROA
dir=/hps/nobackup/production/ensembl/anja/release_92/$species/
bsub -q production-rh7 -M 2000 -R "rusage[mem=2000]" -J run_${species}_gts -o $dir/${species}_gts.out -e $dir/${species}_gts.err perl population_genotypes_92.pl $species $population 
