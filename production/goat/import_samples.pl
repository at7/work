use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup/production/ensembl/anja/release_92/goat/variation_qc/ensembl.registry');
my $species = 'goat';
my $dbh = $registry->get_DBAdaptor('goat', 'variation')->dbc->db_handle;
my $sample_adaptor = $registry->get_adaptor($species, 'variation', 'sample');
my $individual_adaptor = $registry->get_adaptor($species, 'variation', 'individual');
my $population_adaptor = $registry->get_adaptor($species, 'variation', 'population');


my $populations = {
  AUCH => {country => 'Australia' , size => 5, dbID => 35},
  FRCH => {country => 'France', size => 4, dbID => 34},
  IRCH => {country => 'Iran', size => 20, dbID => 37},
  ITCH => {country => 'Italy', size => 5, dbID => 36},
  MOCH => {country => 'Morocco', size => 161, dbID => 33 },
};


import_sample_populations();

sub import_sample_populations {

  foreach my $population (keys %$populations) {
    my $dbID = $populations->{$population}->{dbID};
    my @sample_ids = ();
    my $sth = $dbh->prepare(qq{
      SELECT sample_id, name FROM sample WHERE name like '%NextGen:$population%';
    }, {mysql_use_result => 1});
    $sth->execute();
    my ($sample_id, $name);
    $sth->bind_columns(\($sample_id, $name));
    while ($sth->fetch) {
      push @sample_ids, $sample_id;
    }
    $sth->finish;
    foreach my $sample_id (@sample_ids) {
      $dbh->do("Insert into sample_population(sample_id, population_id) values($sample_id, $dbID)") or die $dbh->errstr;
    }
  }

}

sub import_populations {
  foreach my $population_name (keys %$populations) {
    my $country = $populations->{$population_name}->{country};
    my $size = $populations->{$population_name}->{size};

    my $population = Bio::EnsEMBL::Variation::Population->new(
          -name     => "NextGeb:$population_name",
          -adaptor  => $population_adaptor,
          -size     => $size,
          -description => "Population from the NextGen project. Country:$country",
        );
    $population_adaptor->store($population);
  }
}

sub import_samples {
my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/goat/AUCH/h', 'r');
#ID MOCH-Z9-2206
#ACCESSION ERS154696
#TAXID 9925
#SCIENTIFIC_NAME Capra hircus
#COMMON_NAME goat
#COUNTRY Morocco
#CLOSEST_CITY Bouarfaa
#CLOSEST_LOCALITY Tandrara
#ESTIMATED_AGE 60 months
#LONGITUDE -2.3 degrees
#BREED local populations
#LATITUDE 33.3833 degrees
#GENDER female
#SAMPLING_DATE 2011-12-18

while (<$fh>) {
  chomp;
  if (/^##Sample/) {
    my $sample_row = $_;
    $sample_row =~ s/^##Sample=<|>$|"//g;
    my @fields = split(',', $sample_row);
    my $map = {};
    foreach my $field (@fields) {
      my ($key, $value) = split('=', $field);
      $map->{$key} = $value;
    }
    my $id = $map->{ID};
    my $gender = $map->{GENDER};
    my @info = ();
    foreach (qw/ACCESSION COUNTRY ESTIMATED_AGE BREED/) {
      if ($map->{$_}) {
        push @info, "$_=$map->{$_}";
      }
    }
    my $description = join('|', @info);
    my $individual = Bio::EnsEMBL::Variation::Individual->new(
          -name            => "NextGen:$id",
          -adaptor         => $individual_adaptor,
          -type_individual => 'partly_inbred',
          -gender          => $gender,
          -description => $description,
        );
    my $sample = Bio::EnsEMBL::Variation::Sample->new(
          -name            => "NextGen:$id",
          -adaptor         => $sample_adaptor,
          -individual => $individual,
          -description => $description,
        );

    $sample_adaptor->store($sample);

  }
}
$fh->close;
}
