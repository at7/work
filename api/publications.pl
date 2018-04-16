use warnings;
use strict;

use Bio::EnsEMBL::Registry;
use FileHandle;

my $registry = 'Bio::EnsEMBL::Registry';
  
$registry->load_registry_from_db(-host => 'ensembldb.ensembl.org',-user => 'anonymous');
  
my $pa = $registry->get_adaptor("human", "variation", "publication");


my $fh = FileHandle->new('pmid_ids', 'r');
my $fh_out = FileHandle->new('pmid_ids.out', 'w');

my $count_pmids = 0;
while (<$fh>) {
  chomp;
  my $publication = $pa->fetch_by_pmid($_);
  if ($publication) {
    $count_pmids++;
    my $variations = $publication->variations;
    foreach my $variation (@$variations) {
      print $fh_out $_, "\t", $variation->name, "\n";
    }
  }
}


$fh->close;
$fh_out->close;
print "PMIDs with variation annotations $count_pmids\n";
