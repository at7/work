use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use DBI;
use FileHandle;
use Bio::DB::Fasta;
use Bio::EnsEMBL::Utils::Sequence qw(reverse_comp expand);
use Bio::EnsEMBL::Variation::Utils::RemappingUtils qw(qc_mapped_vf);


my $dir = '/hps/nobackup2/production/ensembl/anja/release_93/zebrafish/post_qc_tests/';

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_93/zebrafish/remapping/ensembl.registry.newasm');

my $vdba = $registry->get_DBAdaptor('Danio_rerio', 'variation');

$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_93/zebrafish/remapping/ensembl.registry.oldasm');
my $vdba_oldasm = $registry->get_DBAdaptor('Danio_rerio', 'variation');

my $fasta_db = '/hps/nobackup2/production/ensembl/anja/release_93/zebrafish/remapping/new_assembly/';
my $config = {
fasta_db => $fasta_db,
mapped_features_file => "$dir/qc_mapped_features/33.txt",
update_features_file => "$dir/qc_update_features/33.txt",
failure_reasons_file => "$dir/qc_failure_reasons/33.txt",
feature_table => 'variation_feature_mapping_results',
vdba => $vdba,
vdba_oldasm => $vdba_oldasm,
};
qc_mapped_vf($config);

