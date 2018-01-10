to_dir_name=/hps/nobackup/production/ensembl/anja/ancestral_alleles/pan_troglodytes_ancestor_Pan_tro_3.0/
for file in /hps/nobackup/production/ensembl/muffato/ancestral_alleles_dump_91/pan_troglodytes_ancestor_Pan_tro_3.0/*; do
    file_name=$(basename $file);
    dir_name=$(dirname $file);
    if [[ "$file_name" =~ ".fa" ]];
    then
      cp "$dir_name/$file_name" "$to_dir_name/$file_name";
    fi
done
