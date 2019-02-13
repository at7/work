perl $HOME/bin/ensembl-vep/vep \
--cache_version 95 \
--db_version 95 \
--dir /nfs/production/panda/ensembl/variation/data/VEP/tabixconverted/ \
--input_file /hps/nobackup2/production/ensembl/anja/vep_data/input/grch37/taiwanese_cohort_DNM_list.vcf \
--output_file /hps/nobackup2/production/ensembl/anja/vep_data/output/grch37/taiwanese_cohort_DNM_list.out \
--force_overwrite \
--cache \
--offline \
--assembly GRCh37 \
--shift_hgvs 1 \
--force_overwrite \
--fork 4 \
--port 3337 \
--af \
--af_gnomad \
--appris \
--biotype \
--canonical \
--ccds \
--check_existing \
--distance 5000 \
--numbers \
--polyphen p \
--pubmed \
--sift p \
--symbol \
--tsl \
--buffer_size 500 \
--regulatory \
--dir_plugins $HOME/bin/VEP_plugins \
--plugin MPC,/nfs/public/release/ensweb-data/latest/tools/grch37/e95/vep/plugin_data/fordist_constraint_official_mpc_values.txt.gz \
--plugin LoFtool,/nfs/public/release/ensweb-data/latest/tools/grch37/e95/vep/plugin_data/LoFtool_scores.txt \
--plugin CADD,/nfs/public/release/ensweb-data/latest/tools/grch37/e95/vep/plugin_data/CADD.tsv.gz,/nfs/public/release/ensweb-data/latest/tools/grch37/e95/vep/plugin_data/CADD_InDels.tsv.gz \
#--port 3337 \
#--regulatory \
# fork buffer size
#--port 3337 \
#{"cache_dir" => "/nfs/public/release/ensweb-data/latest/tools/grch37/e95/vep/cache","code_root" => "/nfs/public/release/ensweb/latest/live/grch37/www_95","config" => {"af" => "yes","appris" => "yes","biotype" => "yes","check_existing" => "yes","coding_only" => "yes","distance" => 5000,"filter_common" => "yes","input_file" => "i-ensemble-annotated.vcf","output_file" => "output.vcf","plugin" => [],"polyphen" => "b","pubmed" => "yes","regulatory" => "yes","sift" => "b","species" => "homo_sapiens","stats_file" => "stats.txt","symbol" => "yes","tsl" => "yes"},"fasta_dir" => "/nfs/public/release/ensweb-data/latest/tools/grch37/e95/vep/fasta","job_id" => 4931026,"plugins_path" => "VEP_plugins","script_options" => {"fork" => 4,"host" => "hh-mysql-ens-grch37-web","port" => 4558,"user" => "ensro"},"species" => "Homo_sapiens","ticket_id" => 2762441,"ticket_name" => "bwb7L2Xv4w4R1HPr","work_dir" => "/nfs/incoming/ensweb/live/grch37/persistent/tools/VEP/b/w/b/7L2Xv4w4R1HPr/1”}
