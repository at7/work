use strict;
use warnings;

use Bio::EnsEMBL::MappedSliceContainer;
use Bio::EnsEMBL::Variation::DBSQL::StrainSliceAdaptor;
use Bio::EnsEMBL::Registry;
use FileHandle;
use DBI;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -db_version => 83,
);

my $set_name = 'HumanCoreExome-12';

my $vsa = $registry->get_adaptor('human', 'variation', 'variationset');
my $attribute_adaptor = $registry->get_adaptor('human', 'variation', 'attribute');

my $dbname = '';
my $host = '';
my $port = 3306;
my $user = ''; 
my $password = '';
my $dbh = DBI->connect("DBI:mysql:database=$dbname;host=$host;port=$port;user=$user;password=$password", {RaiseError => 1});


combine_set_tables();

sub combine_set_tables {
  $dbh->do(qq{INSERT INTO variation_set_variation SELECT * FROM variation_set_variation_core_exome;}) or die $dbh->errstr;
}

sub final_import {
  my $set_id = 40;
  my $variation_ids = {};
  my $path = '';
  foreach my $file (qw/variation_ids_non_dbsnp.txt variation_ids.txt/) {
    my $fh = FileHandle->new("$path/$file", 'r');
    while (<$fh>) {
      chomp;
      $variation_ids->{$_} = 1;
    }
    $fh->close();
  }
  foreach my $variation_id (keys %$variation_ids) {  
    $dbh->do(qq{INSERT INTO variation_set_variation_core_exome(variation_id, variation_set_id) VALUES($variation_id, 40);}) or die $dbh->errstr;
  }
}

sub get_new_variation_ids_non_dbsnp {

  my $variation_ids = {};
  my $id;
  my $sth = $dbh->prepare(qq{ SELECT variation_id FROM variation WHERE source_id=51; });
  $sth->execute();
  $sth->bind_columns(\($id));
  while ($sth->fetch) {
    $variation_ids->{$id} = 1;
  }
  $sth->finish;

  my $fh = FileHandle->new('variation_ids_non_dbsnp.txt', 'w');

  foreach my $variation_id (keys %$variation_ids) {
    print $fh $variation_id, "\n";
  }
  $fh->close();
}

sub get_new_variation_ids {
  my $variant_ids = {};
  my $names = {};
  my $id;

  my $fh = FileHandle->new('core_exome_dbsnp_83.txt', 'r'); 

  while (<$fh>) {
    chomp;
    my $name = $_;
    $names->{$name} = 1;
    my $sth = $dbh->prepare(qq{ SELECT variation_id FROM variation WHERE name='$name'; });
    $sth->execute();
    $sth->bind_columns(\($id));
    $sth->fetch;
    if ($id) {
      if ($variant_ids->{$id}) {
       print STDERR "variation_id for $name duplicated\n";
      }
      $variant_ids->{$id} = 1;
    } else {
      print STDERR "NO variation_id for $name\n";
    } 
    $sth->finish;
  }
  $fh->close();

  $fh = FileHandle->new('variation_ids.txt', 'w');

  foreach my $id (keys %$variant_ids) {
    print $fh $id, "\n";
  }

  $fh->close;

  print STDERR 'variation_ids ', scalar keys %$variant_ids, "\n";
  print STDERR 'names ', scalar keys %$names, "\n";
}

sub pre_set_creation {
  my $non_dbsnp_name2id = {};
  my $dbsnp_name2id = {};
  my $seq_region_name2id = {};
  my $allele_code_84 = {};

  my ($seq_region_id, $variation_id, $name, $allele, $allele_code_id);

  my $sth = $dbh->prepare(qq{ SELECT variation_id, name FROM variation WHERE source_id=51; });
  $sth->execute();
  $sth->bind_columns(\($variation_id, $name));
  while ($sth->fetch) {
    $non_dbsnp_name2id->{$name} = $variation_id;
  }
  $sth->finish;

  $sth = $dbh->prepare(qq{ SELECT seq_region_id, name FROM seq_region; });
  $sth->execute();
  $sth->bind_columns(\($seq_region_id, $name));
  while ($sth->fetch) {
    $seq_region_name2id->{$name} = $seq_region_id;
  }
  $sth->finish;

  $sth = $dbh->prepare(qq{ SELECT allele_code_id, allele FROM allele_code});
  $sth->execute();
  $sth->bind_columns(\($allele_code_id, $allele));
  while ($sth->fetch) {
    $allele_code_84->{$allele} = $allele_code_id;
  }
  $sth->finish;

  my $variation_set = $vsa->fetch_by_name($set_name);
  my $variations = $variation_set->get_all_Variations();

  my $fh_dbsnp = FileHandle->new('core_exome_dbsnp_83.txt', 'w');
  #my $fh_non_dbsnp = FileHandle->new('core_exome_non_dbsnp_variants.txt', 'w');
  #my $fh_non_dbsnp_vf = FileHandle->new('core_exome_non_dbsnp_VFs.txt', 'w');
  my $fh_non_dbsnp_allele = FileHandle->new('core_exome_non_dbsnp_alleles.txt', 'w');
  my $fh_allele_code = FileHandle->new('allele_code.txt', 'w');

  my $exome_chip_source_id = 51;

  foreach my $variant (@$variations) {
    if ($variant->source_name eq 'dbSNP') {
      print $fh_dbsnp $variant->name, "\n";
    } else {
      my $name = $variant->name; 
      $variation_id = $non_dbsnp_name2id->{$name};
      my $var_class = $variant->var_class;
      my $class_attrib_id = $attribute_adaptor->attrib_id_for_type_value('SO_term', $var_class);
      if (!$class_attrib_id) {
        if ($var_class eq 'SNP') {
          $class_attrib_id = 2;
        }
      }
      unless ($name && $class_attrib_id) {
        die "Undefiened values for $name $var_class";
      }

  #    print $fh_non_dbsnp "insert into variation(source_id, name, class_attrib_id, display) values ($exome_chip_source_id, '$name', $class_attrib_id, 1);\n";

      my $vfs = $variant->get_all_VariationFeatures;
      foreach my $vf (@$vfs) {
        my $seq_region = $vf->seq_region_name;
        my $seq_region_id = $seq_region_name2id->{$seq_region};
        my $seq_region_start = $vf->seq_region_start;
        my $seq_region_end = $vf->seq_region_end;
        my $seq_region_strand = $vf->seq_region_strand;
        my $allele_string = $vf->allele_string;
        my $map_weight = $vf->map_weight;
  #      print $fh_non_dbsnp_vf "Insert into variation_feature(source_id, seq_region_id, seq_region_start, seq_region_end, seq_region_strand, allele_string, variation_name, map_weight, variation_id, display, class_attrib_id) values($exome_chip_source_id, $seq_region_id, $seq_region_start, $seq_region_end, $seq_region_strand, '$allele_string', '$name', $map_weight, $variation_id, 1, $class_attrib_id);\n";
       
      }

      my $alleles = $variant->get_all_Alleles;
      foreach my $allele_object (@$alleles) {
        my $allele = $allele_object->allele;
        if (!$allele_code_84->{$allele}) {
          print $fh_allele_code "INSERT into allele_code(allele) values('$allele');\n"
        } else {
          my $allele_code_id = $allele_code_84->{$allele};
          print $fh_non_dbsnp_allele "Insert into allele(variation_id, allele_code_id) values($variation_id, $allele_code_id);\n";
        }
      }
    }
  }

  $fh_dbsnp->close();
  #$fh_non_dbsnp->close();
  #$fh_non_dbsnp_vf->close();
  $fh_non_dbsnp_allele->close();
  $fh_allele_code->close();
}
