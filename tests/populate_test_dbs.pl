use Bio::EnsEMBL::Test::MultiTestDB;
my $path = '/ensembl-rest/t';
my $species = 'homo_sapiens';
my $test = Bio::EnsEMBL::Test::MultiTestDB->new($species, $path);
