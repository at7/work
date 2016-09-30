use strict;
use warnings;

use Data::Dumper;
use HTTP::Tiny;
use JSON;
 
local $Data::Dumper::Terse = 1;
local $Data::Dumper::Indent = 1;

my $http = HTTP::Tiny->new();
 
my $ext = '/variation/human/rs56116432?genotypes=1';

#GET lookup/symbol/:species/:symbol
$ext = '/lookup/symbol/homo_sapiens/FOXP2?expand=1';
my $response = send_request($ext);
my $transcripts = $response->{Transcript};
my @canonical_transcripts = grep {$_->{is_canonical}} @$transcripts;
my $canonical_transcript = $canonical_transcripts[0];
my $transcript_stable_id = $canonical_transcript->{id};
print $transcript_stable_id, "\n";

#GET overlap/id/:id
$ext = "/overlap/id/$transcript_stable_id?feature=variation";
$response = send_request($ext);

my $consequence_types = {};
foreach my $feature (@$response) {
  $consequence_types->{$feature->{consequence_type}}++;
}
foreach my $type (sort keys %$consequence_types) {
  print $type, ' ', $consequence_types->{$type}, "\n"; 
}

my @variants = grep {$_->{consequence_type} eq 'missense_variant' } @$response;
print 'missense variants ', scalar @variants, "\n";

#GET variation/:species/:id
my $variant_name = 'rs555128980';
$ext = "/variation/human/$variant_name";
$response = send_request($ext);
#print Dumper $response, "\n";

foreach my $variant_name (qw/rs201649896/) {
  $ext = "/variation/human/$variant_name?population_genotypes=1&phenotypes=1";
  $response = send_request($ext);
# phenotypes, population_genotypes, risk allele in population genotypes
  print Dumper $response, "\n";
}

#GET vep/:species/region/:region/:allele/
#$ext = '/vep/human/region/1:6524705:6524705/T';
$ext = '/vep/human/region/1:6524705:6524705/C';
$response = send_request($ext);
print Dumper $response, "\n";


sub send_request {
  my $ext = shift;
  my $server = 'http://test.rest.ensembl.org';
  my $response = $http->get($server.$ext, {
    headers => { 'Content-type' => 'application/json' }
  });
  if (!$response->{success}) {
#    while (my ($key, $value) = each %$response) {
#      print "$key $value\n";
#    }
    die "Failed! Reason: $response->{reason}, Content: $response->{content}, \n" ;
  }

  return decode_json($response->{content});
}

sub print_response {
  my $respnse = shift;
  my $hash = decode_json($response);
  print Dumper $hash;
  print "\n";
}


# fetch all variants in FOXP2 gene,  print phenotypes, genotypes

# compute variant effect

