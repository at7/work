use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Slice qw(split_Slices);
use FileHandle;
use DBI;

my $working_dir = '/hps/nobackup/production/ensembl/anja/allele_frequencies_37/';

my $registry = 'Bio::EnsEMBL::Registry';
my $registry_file = '/hps/nobackup/production/ensembl/anja/release_90/dumps_human_37/ensembl.registry';
my $species = 'human';
die "Could not find registry_file $registry_file" unless (-e $registry_file);
$registry->load_all($registry_file);

my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $cdba = $registry->get_DBAdaptor($species, 'core');

my $vfa = $vdba->get_VariationFeatureAdaptor;
my $pa = $vdba->get_PopulationAdaptor;

my $populations = {
    'HAPMAP' => {
        'CSHL-HAPMAP:HAPMAP-ASW' => 'ASW',
        'CSHL-HAPMAP:HAPMAP-CHB' => 'CHB',
        'CSHL-HAPMAP:HAPMAP-CHD' => 'CHD',
        'CSHL-HAPMAP:HAPMAP-GIH' => 'GIH',
        'CSHL-HAPMAP:HAPMAP-LWK' => 'LWK',
        'CSHL-HAPMAP:HAPMAP-MEX' => 'MEX',
        'CSHL-HAPMAP:HAPMAP-MKK' => 'MKK',
        'CSHL-HAPMAP:HAPMAP-TSI' => 'TSI',
        'CSHL-HAPMAP:HapMap-CEU' => 'CEU',
        'CSHL-HAPMAP:HapMap-HCB' => 'HCB',
        'CSHL-HAPMAP:HapMap-JPT' => 'JPT',
        'CSHL-HAPMAP:HapMap-YRI' => 'YRI',
    },
    'ESP' => {
        'ESP6500:African_American'  => 'AA',
        'ESP6500:European_American' => 'EA',
    },
};


my $fhs = {};

foreach my $group (qw/HAPMAP ESP/) {
    foreach my $name (keys %{$populations->{$group}}) {
        my $short_name = $populations->{$group}->{$name};
        my $population = $pa->fetch_by_name($name);
        my $dbid = $population->dbID();
        my $fh = FileHandle->new("$working_dir/$group/$short_name.txt", 'w');        
        $fhs->{$dbid} = $fh;
    }
}

my $dbh = $vdba->dbc->db_handle;
my $sth = $dbh->prepare(qq{
    SELECT a.variation_id, ac.allele, a.frequency, a.population_id
    FROM allele a, allele_code ac
    WHERE a.allele_code_id = ac.allele_code_id
}, {mysql_use_result => 1});
$sth->execute();
my ($variation_id, $allele, $frequency, $population_id);
$sth->bind_columns(\($variation_id, $allele, $frequency, $population_id));
while ($sth->fetch) {
    if ($population_id) {
        if ($fhs->{$population_id}) {
            my $fh = $fhs->{$population_id};
            print $fh join("\t", ($variation_id, $allele, $frequency)), "\n";
        }
    }
}

$sth->finish();

foreach my $id (keys %$fhs) {
    my $fh = $fhs->{$id};
    $fh->close();
}


sub dump_with_sql {
    my $slices = shift;
    my $dbh = $vdba->dbc->db_handle;
    my $sth = $dbh->prepare(qq{
        select variation_name, variation_id from variation_feature where seq_region_id=?;
    }, {mysql_use_result => 1});

    foreach my $slice (@$slices) {
        my $seq_region_name = $slice->seq_region_name;
        my $seq_region_id = $slice->get_seq_region_id;
        my $fh = FileHandle->new("$working_dir/$seq_region_name.txt", 'w');
        $sth->execute($seq_region_id);
        my ($variation_name, $variation_id);
        $sth->bind_columns(\($variation_name, $variation_id));
        while ($sth->fetch()) {
            print $fh "$variation_name\t$variation_id\n";
        }
        $fh->close();
    }
    $sth->finish();
}



