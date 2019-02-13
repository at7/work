use strict;
use warnings;
use FileHandle;
use Bio::EnsEMBL::Registry;
use Data::Dumper;
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_96/vervet/ensembl.registry');

my $species = 'vervet';

#my $sample_adaptor = $registry->get_adaptor($species, 'variation', 'sample');
#my $individual_adaptor = $registry->get_adaptor($species, 'variation', 'individual');
#my $population_adaptor = $registry->get_adaptor($species, 'variation', 'population');

my $vdba = $registry->get_DBAdaptor($species, 'variation');

my $dbh = $vdba->dbc->db_handle;


# update sex: Male, Female
my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_96/vervet/bio_samples_annotations', 'r');
while (<$fh>) {
  chomp;
  my @values = split/\t/;
  my $name = $values[0];
  my $sex = ucfirst $values[2];
  if ($sex eq 'Female' || $sex eq 'Male') {
    $dbh->do(qq{UPDATE individual SET gender='$sex' WHERE name='$name';}) or die $dbh->errstr;
  }
}

$fh->close;

=begin

$fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_96/vervet/sample_population', 'r');

my $population2sample = {};
my $samples = {};
while (<$fh>) {
  chomp;
  next if /^study_id/;
  my ($sample_name, $population_name) =   split(/\s/, $_, 2);
  $population_name =~ s/^\s+|\s+$//g; 
  $population2sample->{$population_name}->{$sample_name} = 1;
  $samples->{$sample_name} = 1;
}
$fh->close;

my $sample_populations = 1;
if ($sample_populations) {
  foreach my $population_name (keys %$population2sample) {
    my $population = $population_adaptor->fetch_by_name($population_name);
    my $population_id = $population->dbID;
    foreach my $sample_name (keys %{$population2sample->{$population_name}}) {
      my $sample_name = $sample_name;
      my $samples = $sample_adaptor->fetch_all_by_name($sample_name);
      my $sample_id = $samples->[0]->dbID;
      $dbh->do(qq{INSERT INTO sample_population(sample_id, population_id) VALUES($sample_id, $population_id);}) or die $dbh->errstr;
    }
  }
}

my $load_populations = 0;
if ($load_populations) {

  foreach my $population_name (keys %$population2sample) {
    my $population = Bio::EnsEMBL::Variation::Population->new(
          -name            => $population_name,
          -adaptor         => $population_adaptor,
          -size => scalar keys %{$population2sample->{$population_name}},
          -description => "Population from EVA study PRJEB22989",
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

  foreach my $name (keys %$samples) {

    my $individual = Bio::EnsEMBL::Variation::Individual->new(
          -name            => $name,
          -adaptor         => $individual_adaptor,
          -type_individual => 'partly_inbred',
          -gender          => 'Unknown',
          -description => 'Individual from EVA study PRJEB22989',
        );
    my $sample = Bio::EnsEMBL::Variation::Sample->new(
          -name            => $name,
          -adaptor         => $sample_adaptor,
          -individual => $individual,
          -description => 'Sample from EVA study PRJEB22989',
        );

    $sample_adaptor->store($sample);
  }
}
=end
=cut
