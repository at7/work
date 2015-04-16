#!/software/bin/perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Variation::DBSQL::DBAdaptor;
use DBI;
use Getopt::Long;

# perl failed_variants.pl -registry ensembl.registry -species human

my $config = {};

GetOptions(
  $config,
  'registry=s',
  'species=s',
) or die "Error: Failed to parse command line arguments\n";

die ('A registry file is required (--registry)') unless (defined($config->{registry}));
die ('A species must be defiened (--species)') unless (defined($config->{species}));

main();

sub main {
  my $registry = 'Bio::EnsEMBL::Registry';
  $registry->load_all($config->{registry});
  my $species = $config->{species};
  my $vdba = $registry->get_DBAdaptor($species, 'variation');
  my $dbh = $vdba->dbc->db_handle;
 
  my $attrib_adaptor = $vdba->get_AttributeAdaptor;
  my $attribs = {
    371 => 'Cited',
    418 => 'Phenotype_or_Disease',
  };
  foreach my $id (keys %$attribs) {
    my $value = $attrib_adaptor->attrib_value_for_id($id);
    if ($attribs->{$id} ne $value) {
      die "Attrib id or value have changed.";
    }
  } 

  foreach my $table (qw/variation variation_feature/) {
    # reset display column, set all values to 1
    $dbh->do(qq{UPDATE $table SET display=1 WHERE display=0;});
    # set display to 0 for failed_variations
    $dbh->do(qq{UPDATE $table t, failed_variation fv SET t.display=0 WHERE fv.variation_id=t.variation_id;});
  }

  # set display to 1 if variation is cited or has phenotypes associated
  foreach my $attrib_id (keys %$attribs) {
    $dbh->do(qq{UPDATE variation SET display=1 WHERE evidence_attribs LIKE '%$attrib_id%';});
    $dbh->do(qq{UPDATE variation_feature vf, variation v SET vf.display=1 WHERE v.variation_id = vf.variation_id AND v.evidence_attribs LIKE '%$attrib_id%';});
  }
  
  my $vsa = $vdba->get_VariationSetAdaptor;
  my $set_name = 'All failed variations';
  my $set = $vsa->fetch_by_name($set_name);
  die "Couldn't get variation set for name: '$set_name'" unless ($set);
  my $set_id = $set->dbID;
  # update failed variation set
  $dbh->do(qq{DELETE FROM variation_set_variation WHERE variation_set_id=$set_id;});
  $dbh->do(qq{INSERT INTO variation_set_variation(variation_id, variation_set_id) SELECT DISTINCT variation_id, $set_id FROM failed_variation;});

}

