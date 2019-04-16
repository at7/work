use JSON qw(decode_json);
use Bio::EnsEMBL::Utils::Exception qw(throw warning);


my $config_file = '/homes/anja/bin/ensembl-variation/modules/Bio/EnsEMBL/Variation/DBSQL/vcf_config.json';
open IN, $config_file or throw("ERROR: Could not read from config file $config_file");
local $/ = undef;
my $json_string = <IN>;
close IN;

my $config = JSON->new->decode($json_string) or throw("ERROR: Failed to parse config file $config_file");
    
