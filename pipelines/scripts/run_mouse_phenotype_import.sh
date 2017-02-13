password=$1
dir=/hps/nobackup/production/ensembl/anja/release_88/mouse/phenotype_data/
script_dir=$HOME/bin/ensembl-variation/scripts/import/
data_source=IMPC
bsub -J import_mouse_phenotype -o ${dir}import_${data_source}_data.out -e ${dir}import_${data_source}_data.err -M1500 -R"select[mem>1500] rusage[mem=1500]" perl ${script_dir}import_phenotype_data.pl \
--host mysql-ens-var-prod-2.ebi.ac.uk \
--dbname mus_musculus_variation_88_38 \
--user ensadmin \
--port 4521 \
--pass $password \
--cdbname mus_musculus_core_88_38 \
--chost mysql-ens-sta-1.ebi.ac.uk \
--cuser ensro \
--cpass '' \
--cport 4519 \
--coord_file ${dir}/MGI_MRK_Coord.rpt \
--working_dir ${dir} \
--source $data_source \
--ontology_dbname ensembl_ontology_88 \
--ontology_host mysql-ens-sta-1.ebi.ac.uk \
--ontology_user ensro \
--ontology_port 4519 \
