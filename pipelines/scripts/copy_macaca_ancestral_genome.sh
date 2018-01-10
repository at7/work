to_dir_name=/hps/nobackup/production/ensembl/anja/ancestral_alleles/macaca_mulatta_ancestor_Mmul_8.0.1/
for file in /hps/nobackup/production/ensembl/muffato/ancestral_alleles_dump_91/macaca_mulatta_ancestor_Mmul_8.0.1/*; do
    file_name=$(basename $file);
    dir_name=$(dirname $file);
    if [[ "$file_name" =~ ".fa" ]];
    then
      cp "$dir_name/$file_name" "$to_dir_name/$file_name";
    fi
done
