use strict;
use warnings;

use Bio::EnsEMBL::Registry;

use FileHandle;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Sequence qw(reverse_comp expand);

my $species = 'chimpanzee';
my $registry_file = '/hps/nobackup/production/ensembl/anja/release_91/chimpanzee/remapping/ensembl.registry.newasm';

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all($registry_file);
my $vdba = $registry->get_DBAdaptor($species, 'variation');

my $dbh = $vdba->dbc->db_handle;

my $feature_table = 'variation_feature_mapping_results';

flip_sample_genotypes();

sub update_features {
  my $dir = '/hps/nobackup/production/ensembl/anja/release_91/chimpanzee/remapping/qc_update_features/';
  opendir(DIR, $dir) or die $!;
  while (my $file = readdir(DIR)) {
    next unless (-f "$dir/$file");
    next unless ($file =~ m/\.txt$/);
    my $fh = FileHandle->new("$dir/$file", 'r');
    while(<$fh>) {
      chomp;
      $dbh->do("$_");
    }
    $fh->close;
  }
  closedir(DIR);
}

sub flip_sample_genotypes {
  my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_91/chimpanzee/remapping/update_sample_genotype_input.txt', 'w');
  my $sth = $dbh->prepare(qq{
  SELECT vf.seq_region_id, vf.seq_region_start, vf.seq_region_end, vf.seq_region_strand, vf.variation_id, vf.variation_name, vf.allele_string, vf.map_weight, sg.subsnp_id, sg.allele_1, sg.allele_2, sg.sample_id
  FROM variation_feature_mapping_results vf
  INNER JOIN tmp_sample_genotype_single_bp sg ON vf.variation_id = sg.variation_id
  WHERE vf.flip = 1
  AND vf.map_weight = 1;
  }, {mysql_use_result => 1});

  $sth->execute();
  while (my $row = $sth->fetchrow_arrayref) {
    my @values = map { defined $_ ? $_ : '\N' } @$row;
    print $fh join("\t", @values), "\n";
  }
  $sth->finish();
  $fh->close();
  $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_91/chimpanzee/remapping/update_sample_genotype_input.txt', 'r');
  while (<$fh>) {
    chomp;
    my ($seq_region_id, $start, $end, $strand, $variation_id, $variation_name, $allele_string, $map_weight, $subsnp_id, $allele_1, $allele_2, $sample_id) = split/\t/;

    # deal with Ns?
    my @alleles = ();
    foreach my $allele ($allele_1, $allele_2) {
      if ($allele eq 'N') {
        push @alleles, $allele;
      } else {
        if (contained_in_allele_string($allele_string, $allele)) {
          push @alleles, $allele;
        } else {
          my $rev_comp_allele = reverse_comp_allele_string($allele);
          if (contained_in_allele_string($allele_string, $rev_comp_allele)) {
            push @alleles, $rev_comp_allele;
          } 
        }
      }
    }   
    if (scalar @alleles == 2 ) {
      @alleles = sort @alleles;
      my $new_allele_1 = $alleles[0];
      my $new_allele_2 = $alleles[1];
# update
    }

  }
  $fh->close();
}


sub flip_alleles {
  my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_91/chimpanzee/remapping/update_allele_input.txt', 'w');
  my $sth = $dbh->prepare(qq{
  SELECT vf.seq_region_id, vf.seq_region_start, vf.seq_region_end, vf.seq_region_strand, vf.variation_id, vf.variation_name, vf.allele_string, vf.map_weight, a.allele_id, a.allele_code_id
  FROM variation_feature_mapping_results vf
  INNER JOIN allele a ON vf.variation_id = a.variation_id
  WHERE vf.flip = 1
  AND vf.map_weight = 1;
  }, {mysql_use_result => 1});

  $sth->execute();
  while (my $row = $sth->fetchrow_arrayref) {
    my @values = map { defined $_ ? $_ : '\N' } @$row;
    print $fh join("\t", @values), "\n";
  }
  $sth->finish();
  $fh->close();

  my $failed_alleles = {};
  my $failed_variations = {};
  $sth = $dbh->prepare(qq{
  SELECT fa.allele_id, fa.failed_description_id 
  FROM variation_feature_mapping_results vf
  INNER JOIN allele a ON vf.variation_id = a.variation_id
  INNER JOIN failed_allele fa ON a.allele_id = fa.allele_id
  WHERE vf.flip = 1
  AND vf.map_weight = 1;
  }, {mysql_use_result => 1});

  $sth->execute();
  while (my $row = $sth->fetchrow_arrayref) {
    my ($allele_id, $failed_description_id) = @$row;
    $failed_alleles->{$allele_id} = 1;
  }
  $sth->finish();

  $sth = $dbh->prepare(qq{
  SELECT fv.variation_id, fv.failed_description_id 
  FROM variation_feature_mapping_results vf
  INNER JOIN allele a ON vf.variation_id = a.variation_id
  INNER JOIN failed_variation fv ON a.variation_id = fv.variation_id
  WHERE vf.flip = 1
  AND vf.map_weight = 1;
  }, {mysql_use_result => 1});

  $sth->execute();
  while (my $row = $sth->fetchrow_arrayref) {
    my ($variation_id, $failed_description_id) = @$row;
    $failed_variations->{$variation_id} = 1;
  }
  $sth->finish();

  my $allele_id_2_string = {};
  my $allele_string_2_id = {};


  $sth = $dbh->prepare(qq{
  SELECT allele_code_id, allele FROM allele_code 
  }, {mysql_use_result => 1});

  $sth->execute();
  while (my $row = $sth->fetchrow_arrayref) {
    my ($allele_code_id, $allele) = @$row;
    $allele_id_2_string->{$allele_code_id} = $allele;
    $allele_string_2_id->{$allele} = $allele_code_id; 
  }
  $sth->finish();

  $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_91/chimpanzee/remapping/update_allele_input.txt', 'r');
  while (<$fh>) {
    chomp;
    my ($seq_region_id, $start, $end, $strand, $variation_id, $variation_name, $allele_string, $map_weight, $allele_id, $allele_code_id) = split/\t/;

    # next if failed_allele 
    next if ($failed_alleles->{$allele_id}); # only for certain failed_descriptions

    next if ($failed_variations->{$variation_id}); # only for certain failed_descriptions

    my $allele = $allele_id_2_string->{$allele_code_id};
    next if (contained_in_allele_string($allele_string, $allele));

    my $rev_comp_allele = reverse_comp_allele_string($allele);

    if (contained_in_allele_string($allele_string, $rev_comp_allele)) {
      # update allele code
      my $new_allele_code = $allele_string_2_id->{$rev_comp_allele};
      if (!$new_allele_code) {
        print STDERR "No new allele code id for $rev_comp_allele\n";
      }
#    print STDERR "$variation_name $allele_string $allele -> $rev_comp_allele\n";

      next;
    }
  }
}

sub flip_genotypes {
  my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_91/chimpanzee/remapping/update_genotype_input.txt', 'w');

  my $sth = $dbh->prepare(qq{
  SELECT vf.seq_region_id, vf.seq_region_start, vf.seq_region_end, vf.seq_region_strand, vf.variation_id, vf.variation_name, vf.allele_string, vf.map_weight, pg.genotype_code_id
  FROM variation_feature_mapping_results vf
  INNER JOIN population_genotype pg ON vf.variation_id = pg.variation_id
  WHERE vf.flip = 1
  AND vf.map_weight = 1;
  }, {mysql_use_result => 1});

  $sth->execute();
  my @results = ();
  while (my $row = $sth->fetchrow_arrayref) {
    my @values = map { defined $_ ? $_ : '\N' } @$row;
    print $fh join("\t", @values), "\n";
  }
  $sth->finish();
  $fh->close();

  my $gtca = $vdba->get_GenotypeCodeAdaptor;

  my $gtcs = $gtca->fetch_all;

  my $gtc_id_2_string = {};
  my $gtc_string_2_id = {};

  foreach my $gtc (@$gtcs) {
    my $gtc_dbID = $gtc->dbID;
    my $alleles = join('/', @{$gtc->genotype});
    $gtc_id_2_string->{$gtc_dbID} = $alleles;
    $gtc_string_2_id->{$alleles} = $gtc_dbID;
  }

  $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_91/chimpanzee/remapping/update_genotype_input.txt', 'r');
  while (<$fh>) {
    chomp;
    my ($seq_region_id, $start, $end, $strand, $variation_id, $variation_name, $allele_string, $map_weight, $genotype_code) = split/\t/;
    my $gtc = $gtca->fetch_by_dbID($genotype_code);

    $allele_string = join('/', sort split('/', $allele_string));

    my $genotype_string = $gtc_id_2_string->{$genotype_code};

    next if ($allele_string eq $genotype_string);

    next if (contained_in_allele_string($allele_string, $genotype_string));

    my $rev_comp_genotype_string = reverse_comp_allele_string($genotype_string);

    if (contained_in_allele_string($allele_string, $rev_comp_genotype_string)) {
      # update genotype code
      my $new_genotype_code = $gtc_string_2_id->{$rev_comp_genotype_string};
      if (!$new_genotype_code) {
        print STDERR "No new genotype code id for $rev_comp_genotype_string\n";
      }
      next;
    }

  #  print STDERR "$variation_name $allele_string $genotype_string -> $rev_comp_genotype_string\n";

}
$fh->close();

}

sub reverse_comp_allele_string {
  my $allele_string = shift;
  my @allele_string_rev_comp = split('/', $allele_string);
  foreach my $allele (@allele_string_rev_comp) {
    reverse_comp(\$allele);
  }
  return join('/', sort @allele_string_rev_comp);
}

sub contained_in_allele_string {
  my $allele_string = shift;
  my $alleles = shift;
  my %lookup = map {$_ => 1} split/\//, $allele_string;

  foreach my $allele (split/\//, $alleles) {
    if (!$lookup{$allele}) {
      return 0;
    }
  }
  return 1;
}






