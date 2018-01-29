use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use FileHandle;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
);

my $pfa = $registry->get_adaptor('human', 'variation', 'phenotypefeature');
my $pa = $registry->get_adaptor('human', 'variation', 'phenotype');
my $vfa = $registry->get_adaptor('human', 'variation', 'variationfeature');

my $sa = $registry->get_adaptor('human', 'core', 'slice');


sub phenotype_variants {


}

#&variants_in_region();

sub variants_in_region {
  # 12: 10,825,664-11,172,248
  my $slice = $sa->fetch_by_region('chromosome', 12, 10825664, 11172248);
  my $vfs = $vfa->fetch_all_by_Slice($slice); 
  my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_92/ld_tool/variants_in_region_12_10825664_11172248', 'w');
  foreach my $vf (@$vfs) {
    print $fh $vf->variation_name, "\n";
  }
  $fh->close;
}

sub phenotypes {
  foreach my $chrom (1..22, 'X', 'Y') {
    my $slice = $sa->fetch_by_region('chromosome', $chrom);
    my $pfs = $pfa->fetch_all_by_Slice_type($slice, 'Variation');
    print $chrom, ' ', scalar @$pfs, "\n";
  }
}
