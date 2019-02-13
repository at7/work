use strict;
use warnings;

use FileHandle;  
use Bio::EnsEMBL::Registry;
use HTTP::Tiny;
use JSON;
use Data::Dumper;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_96/ensembl.registry');

my $bio_samples_desc = 1;

if ($bio_samples_desc) {
#curl -H Content-Type:application/json https://www.ebi.ac.uk/biosamples/api/samples/search
  my $http = HTTP::Tiny->new();
  my $fh =  FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_96/vervet/sample_names', 'r');
  my $fh_out = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_96/vervet/bio_samples_annotations', 'w');
  while (<$fh>) {
    chomp;
    my ($sample_name) = split/\t/;
    my $server = "https://www.ebi.ac.uk/biosamples/api/samples/search/findByAccession?accession=$sample_name";
    my $response = $http->get($server, {
      headers => { 'Content-type' => 'application/json' }
    });

    die "Failed!\n" unless $response->{success};
    if(length $response->{content}) {
      my $hash = decode_json($response->{content});
      my $embedded = $hash->{_embedded};
      if ($embedded->{samples}) {
        my @samples = @{$embedded->{samples}};
        if (scalar @samples) {
        if (scalar @samples > 1) {
          @samples = grep {$_->{name} eq $sample_name} @samples;
          print STDERR "$sample_name more than one sample\n";
        }
         # 'characteristics' => {
         #   'breed' => [
         #    {
         #     'text' => 'Merino_Horned'
         #    }
         #    ],

        my $sample =  $samples[0];
        my $sex = $sample->{characteristics}->{sex}[0]->{text} || 'NA';
        my $breed =  $sample->{characteristics}->{breed}[0]->{text} || 'NA';
        my $accession = $sample->{accession} || 'NA';
        my $description = $sample->{description} || 'NA';
        print $fh_out "$sample_name\t$accession\t$sex\t$breed\t$description\n";
        }
#      local $Data::Dumper::Terse = 1;
#      local $Data::Dumper::Indent = 1;
#      print STDERR Dumper $hash;
#      print STDERR "\n";
      }
#      local $Data::Dumper::Terse = 1;
#      local $Data::Dumper::Indent = 1;
#      print Dumper $hash;
#      print "\n";
    }
  }
  $fh->close;
  $fh_out->close;
}


