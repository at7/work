bsub -q production-rh7 -M 10000 -R "rusage[mem=10000]"  -J VCF_1000G -o /hps/nobackup/production/ensembl/anja/release_91/dumps_human/VCF_1000G.out -e /hps/nobackup/production/ensembl/anja/release_91/dumps_human/VCF_1000G.err perl assign_1000G_frequencies.pl 
