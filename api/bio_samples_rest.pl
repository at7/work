use strict;
use warnings;

use FileHandle;  
use Bio::EnsEMBL::Registry;
use HTTP::Tiny;
use JSON;
use Data::Dumper;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_all('/hps/nobackup/production/ensembl/anja/release_92/sheep/ensembl.registry');

my $species = 'sheep';

my $vca = $registry->get_adaptor($species, 'variation', 'vcfcollection');

$vca->db->use_vcf(1);

my $print_samples = 0;
if ($print_samples) {
  my $c = $vca->fetch_by_id('sheep_genome_consortium');
  my $samples = $c->get_all_Samples;
  my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/sheep/sheep_genome_project_samples', 'w');
  foreach my $sample (@$samples) {
    my $sample_name = $sample->name;
    my $first_letter_code = substr($sample_name, 0, 2);
    my $second_letter_code = substr($sample_name, 2, 3);
    print $fh "$sample_name\t$first_letter_code\t$second_letter_code\n";
  }
  $fh->close;
}
my $assign_breed = 0;
if ($assign_breed) {
  my $breed_code_2_breed = {};
  my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/sheep/breed_code', 'r');
  while (<$fh>) {
    chomp;
    next if (/^BreedCode/);
    my @values = split(/\s/, $_, 2);
    $breed_code_2_breed->{$values[0]} = $values[1];
  }
  $fh->close;

  my $population2sample = {};
  $fh =  FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/sheep/sheep_genome_project_samples', 'r');
  while (<$fh>) {
    chomp;
    my ($sample, $country_code, $breed_code) = split/\t/;
    my $breed = $breed_code_2_breed->{$breed_code};
    if (!$breed) {
      print $_, "\n";
    } else {
      $population2sample->{$breed}->{$sample} = 1;
    }
  }
  $fh->close();  

  foreach my $name (sort {scalar keys %{$population2sample->{$b}} <=> scalar keys %{$population2sample->{$a}}} keys %$population2sample) {
    print STDERR $name, ' ', scalar keys %{$population2sample->{$name}}, "\n";
  } 
}

my $bio_samples_desc = 1;

if ($bio_samples_desc) {
#curl -H Content-Type:application/json https://www.ebi.ac.uk/biosamples/api/samples/search
  my $http = HTTP::Tiny->new();
  my $fh =  FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/sheep/sheep_genome_project_samples', 'r');
  my $fh_out = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/sheep/bio_samples_annotations', 'w');
  while (<$fh>) {
    chomp;
    my ($sample_name, $country_code, $breed_code) = split/\t/;
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
        if (scalar @samples > 1) {
          print STDERR "$sample_name more than one sample\n";
        } elsif (@samples == 1) {
         # 'characteristics' => {
         #   'breed' => [
         #    {
         #     'text' => 'Merino_Horned'
         #    }
         #    ],

          my $sample =  $samples[0];
          my $sex = $sample->{characteristics}->{sex}[0]->{text} || 'NA';
          my $breed =  $sample->{characteristics}->{breed}[0]->{text} || 'NA';
          my $accession = $sample->{accession};
          print $fh_out "$sample_name\t$accession\t$sex\t$breed\n";
#      local $Data::Dumper::Terse = 1;
#      local $Data::Dumper::Indent = 1;
#      print Dumper $hash;
#      print "\n";
        }
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


