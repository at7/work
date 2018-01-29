use strict;
use warnings;
use FileHandle;
use Bio::EnsEMBL::Registry;
use Data::Dumper;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_all('/hps/nobackup/production/ensembl/anja/release_92/sheep/ensembl.registry');

my $species = 'sheep';

my $sample_adaptor = $registry->get_adaptor($species, 'variation', 'sample');
my $individual_adaptor = $registry->get_adaptor($species, 'variation', 'individual');
my $population_adaptor = $registry->get_adaptor($species, 'variation', 'population');

my $vdba = $registry->get_DBAdaptor($species, 'variation');

my $dbh = $vdba->dbc->db_handle;

my $sample_populations = 1;

if ($sample_populations) {
  my $breed_codes = {};
  my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/sheep/breed_code', 'r'); 
  while (<$fh>) {
    chomp;
    next if (/^BreedCode/);
    my @values = split(/\s/, $_, 2);
    $breed_codes->{$values[0]} = $values[1];
  }
  $fh->close;
  my $population2sample = {};
  $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/sheep/sheep_genome_project_samples', 'r'); 
  while (<$fh>) {
    chomp;
    my ($name, $country, $breed_code) = split/\t/;
    my $breed = $breed_codes->{$breed_code};
    $population2sample->{$breed}->{$name} = 1;
  }
  $fh->close;
  foreach my $population_name (keys %$population2sample) {
    my $population = $population_adaptor->fetch_by_name("ISGC:$population_name");
    my $population_id = $population->dbID;
    foreach my $sample_name (keys %{$population2sample->{$population_name}}) {
      my $sample_name = "ISGC:$sample_name";
      my $samples = $sample_adaptor->fetch_all_by_name($sample_name);
      my $sample_id = $samples->[0]->dbID;
      $dbh->do(qq{INSERT INTO sample_population(sample_id, population_id) VALUES($sample_id, $population_id);}) or die $dbh->errstr;
    }
  }
}

my $load_populations = 0;
if ($load_populations) {
  my $breed_codes = {};
  my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/sheep/breed_code', 'r'); 
  while (<$fh>) {
    chomp;
    next if (/^BreedCode/);
    my @values = split(/\s/, $_, 2);
    $breed_codes->{$values[0]} = $values[1];
  }
  $fh->close;
  my $population2sample = {};
  $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/sheep/sheep_genome_project_samples', 'r'); 
  while (<$fh>) {
    chomp;
    my ($name, $country, $breed_code) = split/\t/;
    my $breed = $breed_codes->{$breed_code};
    $population2sample->{$breed}->{$name} = 1;
  }
  $fh->close;

  foreach my $population_name (keys %$population2sample) {
    my $population = Bio::EnsEMBL::Variation::Population->new(
          -name            => "ISGC:$population_name",
          -adaptor         => $population_adaptor,
          -size => scalar keys %{$population2sample->{$population_name}},
          -description => "Population from International Sheep Genome Consortium",
        );
    $population_adaptor->store($population);
  }


}



my $load_samples = 0;
if ($load_samples) {
  my $gender_mappings = {
    'male' => 'Male',
    'female' => 'Female',
    'NA' => 'Unknown',
  };
  my $sample2sex = {};
  my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/sheep/bio_samples_annotations', 'r'); 
  while (<$fh>) {
    chomp;
    my ($name, $accession, $sex, $breed) = split/\t/;
    my $gender = $gender_mappings->{$sex};
    if (!$gender) {
      print STDERR $_, "\n";
    } else {
      $sample2sex->{$name} = $gender;
    }
  }

  my $breed_codes = {};

  $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/sheep/breed_code', 'r'); 
  while (<$fh>) {
    chomp;
    next if (/^BreedCode/);
    my @values = split(/\s/, $_, 2);
    $breed_codes->{$values[0]} = $values[1];
  }
  $fh->close;
  $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/sheep/sheep_genome_project_samples', 'r'); 
  while (<$fh>) {
    chomp;
    my ($name, $country, $breed_code) = split/\t/;
    my $breed = $breed_codes->{$breed_code};
    if (!$breed) {
    print STDERR $breed_code, "\n";
    }
    my $description = "Breed:$breed|Sample from International Sheep Genome Consortium";
    my $gender = $sample2sex->{$name} || 'Unknown';
    my $individual = Bio::EnsEMBL::Variation::Individual->new(
          -name            => "ISGC:$name",
          -adaptor         => $individual_adaptor,
          -type_individual => 'partly_inbred',
          -gender          => $gender,
          -description => $description,
        );
    my $sample = Bio::EnsEMBL::Variation::Sample->new(
          -name            => "ISGC:$name",
          -adaptor         => $sample_adaptor,
          -individual => $individual,
          -description => $description,
        );

#    $sample_adaptor->store($sample);
  }
}
