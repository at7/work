use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use DBI;
use FileHandle;
use Bio::DB::Fasta;
use Bio::EnsEMBL::Utils::Sequence qw(reverse_comp expand);
use Bio::EnsEMBL::Variation::Utils::RemappingUtils qw(filter_svf_mapping);


my $dir = '/hps/nobackup2/production/ensembl/anja/release_94/dog/remapping/';


#my $registry = 'Bio::EnsEMBL::Registry';
#$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_93/zebrafish/remapping/ensembl.registry.newasm');
#my $vdba = $registry->get_DBAdaptor('Danio_rerio', 'variation');
#$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_93/zebrafish/remapping/ensembl.registry.oldasm');
#my $vdba_oldasm = $registry->get_DBAdaptor('Danio_rerio', 'variation');
#my $fasta_db = '/hps/nobackup2/production/ensembl/anja/release_93/zebrafish/remapping/new_assembly/';



my $config = {
  file_prev_mappings => "$dir/dump_features/lookup_1.txt",
  file_mappings => "$dir/mapping_results/mappings_1.txt",
  file_filtered_mappings => "$dir/filtered_mappings.txt",
file_failed_filtered_mappings
};
filter_svf_mapping($config);

