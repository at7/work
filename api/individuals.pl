use strict;
use warnings;

require "../utils/db.pl";
use Bio::EnsEMBL::Registry;
use Getopt::Long;

# perl individuals.pl -db_config db_config

my $config = {};

GetOptions(
  $config,
  'db_config=s',
  'registry=s',
  'mode=s',
) or die "Error: Failed to parse command line arguments\n";

create_samples() if ($config->{mode} eq 'create_samples');
test_new_schema() if ($config->{mode} eq 'test_new_schema');

sub test_new_schema {
  die ('A registry file is required (--registry)') unless (defined($config->{registry}));
  my $registry_file = $config->{registry};
  my $registry = 'Bio::EnsEMBL::Registry';
  $registry->load_all($registry_file);

  my $ia = $registry->get_adaptor('rat', 'variation', 'individual'); 
  my $individuals = $ia->fetch_all();
  # fetch_all_Samples_by_Individual($individual);
  # 

  foreach my $i (@$individuals) {
    print $i->name, "\n";
  }
=begin
  Create a new study:
  my $study_wgs = Bio::EnsEMBL::Variation::Study->new(-name => 'WGS');
  my $study_exome = Bio::EnsEMBL::Variation::Study->new(-name => 'Exome'); 
  my $individual = $individual_adaptor->fetch_by_name('NA12345'); 
  my $first_sample = Bio::EnsEMBL::Variation::Individual->new(
                      -individual => $individual,
                      -study => $study_wgs,
                      -is_sample => 1,  
                     );
  $individual_adaptor->store($first_sample);
  ...  

  Genotypes
  my $individual_genotypes = $indivdiual_genotype_adaptor->fetch_all_by_Variation($variation);
  my $individual_genotypes = $indivdiual_genotype_adaptor->fetch_all_by_Variation($variation, $study);

=end
=cut
}

sub create_samples {
  my $individuals = {};
  my $is_sample = {};
  die ('A db_config file is required (--db_config)') unless (defined($config->{db_config}));
  my $dbh = get_dbh($config->{db_config});  
  my $stmt = qq{SELECT individual_id, name, description FROM individual;};

  my $sth = $dbh->prepare($stmt) or die $dbh->errstr;
  $sth->execute() or die $sth->errstr;
  while (my $row = $sth->fetchrow_arrayref) {
    my @values = map { defined $_ ? $_ : '\N' } @$row;
    my $individual_id = $values[0];
    my $name = $values[1];
    my $description = $values[2];
    $individuals->{$name}->{$individual_id} = $description;
  }
  $sth->finish();
 
  foreach my $name (keys %$individuals) {
    if (scalar keys %{$individuals->{$name}} > 1) {
      $dbh->do(qq{INSERT INTO individual(name) VALUES('$name');}) or die $dbh->errstr;
      my $individual_id = $dbh->last_insert_id(undef, undef, 'individual', 'individual_id');
      foreach my $sample_id (keys %{$individuals->{$name}}) {
        $dbh->do(qq{UPDATE individual SET is_sample=1 WHERE individual_id=$sample_id;}) or die $dbh->errstr;
        $dbh->do(qq{INSERT INTO individual_sample(individual_id, sample_id) VALUES($individual_id, $sample_id);});
      }
    } 
  } 
}
