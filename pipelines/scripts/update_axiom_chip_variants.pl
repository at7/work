=begin
WU_10_2_17_38278486
WU_10_2_14_6161656
WU_10_2_12_21260610
WU_10_2_4_139615249
WU_10_2_12_18261411
WU_10_2_2_81969698
WU_10_2_6_88714151
WU_10_2_12_17977349


INSERT INTO helens_sus_scrofa_variation_91_111.variation(source_id, name, class_attrib_id, display) select source_id, name, class_attrib_id, display from variation_axiom_chip_91;

ALTER table variation_axiom_chip_91 add column variation_id_91 int(10) unsigned;

insert into helens_sus_scrofa_variation_91_111.variation_feature(seq_region_id, seq_region_start, seq_region_end, seq_region_strand, variation_id, allele_string, variation_name, map_weight, source_id, class_attrib_id, alignment_quality, display) select seq_region_id, seq_region_start, seq_region_end, seq_region_strand, variation_id_91, allele_string, variation_name, map_weight, source_id, class_attrib_id, alignment_quality, display from variation_feature_axiom_chip_91;
=end
=cut
use strict;
use warnings;


use DBI;
use Bio::EnsEMBL::Registry;
use FileHandle;


#my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/release_91/pig/merged_variations_axiom_chip', 'w');

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup/production/ensembl/anja/release_91/pig/ensembl.registry.axiom_chip');
my $vdba = $registry->get_DBAdaptor('pig', 'variation');

my $dbh = $vdba->dbc->db_handle();

=begin
$dbh->do(qq{
INSERT INTO variation_feature_axiom_chip_merged_91(seq_region_id, seq_region_start, seq_region_end, seq_region_strand, variation_id, allele_string, variation_name, variation_name_dbsnp, variation_id_91) 
SELECT vf.seq_region_id, vf.seq_region_start, vf.seq_region_end, vf.seq_region_strand, mr.variation_id, vf.allele_string, mr.variation_name, vf.variation_name, vf.variation_id
FROM helens_sus_scrofa_variation_91_111.variation_feature vf, variation_feature_axiom_chip_mapping_results_111 mr
WHERE vf.seq_region_id = mr.seq_region_id
AND vf.seq_region_start = mr.seq_region_start
AND vf.seq_region_end = mr.seq_region_end
AND vf.allele_string = mr.allele_string
});
=end
=cut

my $sth = $dbh->prepare(qq{
SELECT variation_id_91 from axiom_chip_set_91
}, {mysql_use_result => 1});

my $variants = {};
$sth->execute() or die $sth->errstr;
while (my $row = $sth->fetchrow_arrayref) {
  my $synonym = $row->[0];
  if ($variants->{$synonym}) {
    print STDERR "DELETE FROM axiom_chip_set_91 where variation_id_91=$synonym;\n";
  }
  $variants->{$synonym} = 1;
}
$sth->finish;
=end
=cut
