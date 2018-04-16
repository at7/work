use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
my $registry_file = '/Users/anja/Documents/development/rest/ensembl.registry';
$registry->load_all($registry_file);


#$registry->load_registry_from_db(
#  -host => 'ensembldb.ensembl.org',
#  -user => 'anonymous',
#);

my $sa = $registry->get_adaptor('human', 'core', 'slice');
my $svfa = $registry->get_adaptor('human', 'variation', 'structuralvariationfeature');


foreach my $chromosome (1, 16, 15, 8 ) {
  my $slice = $sa->fetch_by_region('chromosome', $chromosome);
  print $slice->length, "\n";
  my $svfs = $svfa->fetch_all_by_Slice($slice);
  print $chromosome, ' ', scalar @$svfs, "\n";
  $svfs = $svfa->fetch_all_somatic_by_Slice($slice);
  print $chromosome, ' somatic ', scalar @$svfs, "\n";
}

my $dbh = $registry->get_DBAdaptor('human', 'variation')->dbc->db_handle;

$dbh->do(qq{insert into structural_variation_feature(structural_variation_feature_id, seq_region_id, outer_start, seq_region_start,  inner_start, inner_end, seq_region_end,  outer_end, seq_region_strand, structural_variation_id, variation_name,  source_id, study_id,  class_attrib_id, allele_string, is_evidence, somatic, breakpoint_order,  length) values(11638719, 131549, 4439859, 4439859, NULL,  NULL,  4439859, 4439859, 1, 11769608,  'essv6661646', 11,  4465,  289, NULL,  1, 1, 1, NULL)}) or die $dbh->errstr;
$dbh->do(qq{insert into structural_variation_feature(structural_variation_feature_id, seq_region_id, outer_start, seq_region_start,  inner_start, inner_end, seq_region_end,  outer_end, seq_region_strand, structural_variation_id, variation_name,  source_id, study_id,  class_attrib_id, allele_string, is_evidence, somatic, breakpoint_order,  length) values(11638970,  27514,  4547864, 4547864, NULL,  NULL,  4547864, 4547864, 1, 11769438,  'essv4488280', 11,  4465,  286, NULL,  1, 1, 1, NULL)}) or die $dbh->errstr;
$dbh->do(qq{insert into structural_variation_feature(structural_variation_feature_id, seq_region_id, outer_start, seq_region_start,  inner_start, inner_end, seq_region_end,  outer_end, seq_region_strand, structural_variation_id, variation_name,  source_id, study_id,  class_attrib_id, allele_string, is_evidence, somatic, breakpoint_order,  length) values(11638683,  27514,  4982287, 4982287, 4982687, 4987063, 4987463, 4987463, -1,  11769636,  'essv4489159', 11,  4465,  211, NULL,  1, 1, 1, NULL)}) or die $dbh->errstr;
$dbh->do(qq{insert into structural_variation_feature(structural_variation_feature_id, seq_region_id, outer_start, seq_region_start,  inner_start, inner_end, seq_region_end,  outer_end, seq_region_strand, structural_variation_id, variation_name,  source_id, study_id,  class_attrib_id, allele_string, is_evidence, somatic, breakpoint_order,  length) values(11647236,  27514,  4982287, 4982287, 4982687, 4987063, 4987463, 4987463, -1,  11776239,  'esv1914296',  11,  4465,  211, NULL,  0, 1, 1, NULL)}) or die $dbh->errstr;
$dbh->do(qq{insert into structural_variation_feature(structural_variation_feature_id, seq_region_id, outer_start, seq_region_start,  inner_start, inner_end, seq_region_end,  outer_end, seq_region_strand, structural_variation_id, variation_name,  source_id, study_id,  class_attrib_id, allele_string, is_evidence, somatic, breakpoint_order,  length) values(11638927,  27514,  4989780, 4989780, NULL,  NULL,  4989780, 4989780, 1, 11769459,  'essv4489263', 11,  4465,  286, NULL,  1, 1, 1, NULL)}) or die $dbh->errstr;

$dbh->do(qq{insert into structural_variation values(11769438,  'essv4488280', NULL,  11,  4465,  286, NULL,  NULL,  1, 1, NULL)}) or die $dbh->errstr;
$dbh->do(qq{insert into structural_variation values(11769459,  'essv4489263', NULL,  11,  4465,  286, NULL,  NULL,  1, 1, NULL)}) or die $dbh->errstr;
$dbh->do(qq{insert into structural_variation values(11769608,  'essv6661646', NULL,  11,  4465,  289, NULL,  NULL,  1, 1, NULL)}) or die $dbh->errstr;
$dbh->do(qq{insert into structural_variation values(11769636,  'essv4489159', NULL,  11,  4465,  211, NULL,  NULL,  1, 1, NULL)}) or die $dbh->errstr;
$dbh->do(qq{insert into structural_variation values(11776239,  'esv1914296',  'COST16848', 11,  4465,  211, NULL,  NULL,  0, 1, NULL)}) or die $dbh->errstr;

$dbh->do(qq{insert into study values(4465,  11,  'estd192', 'Catalogue of Somatic Mutations in Cancer (COSMIC) version 61',  'ftp://ftp.ebi.ac.uk/pub/databases/dgva/estd192_COSMIC http://cancer.sanger.ac.uk/cancergenome/projects/cosmic/',  'Somatic', NULL)}) or die $dbh->errstr;


=begin
select svf.*
from structural_variation_feature svf, seq_region sr
where sr.seq_region_id = svf.seq_region_id
and sr.name = '16'
and svf.seq_region_start >= 4000000
and svf.seq_region_end <= 5000000
and svf.`somatic` = 1
limit 10;

Add somatic structural variation data
structural_variation_feature_id seq_region_id outer_start seq_region_start  inner_start inner_end seq_region_end  outer_end seq_region_strand structural_variation_id variation_name  source_id study_id  class_attrib_id allele_string is_evidence somatic breakpoint_order  length  variation_set_id
structural_variation_feature
11638719  131549  4439859 4439859 NULL  NULL  4439859 4439859 1 11769608  essv6661646 11  4465  289 NULL  1 1 1 NULL  
11638970  131549  4547864 4547864 NULL  NULL  4547864 4547864 1 11769438  essv4488280 11  4465  286 NULL  1 1 1 NULL  
11638683  131549  4982287 4982287 4982687 4987063 4987463 4987463 -1  11769636  essv4489159 11  4465  211 NULL  1 1 1 NULL  
11647236  131549  4982287 4982287 4982687 4987063 4987463 4987463 -1  11776239  esv1914296  11  4465  211 NULL  0 1 1 NULL  
11638927  131549  4989780 4989780 NULL  NULL  4989780 4989780 1 11769459  essv4489263 11  4465  286 NULL  1 1 1 NULL  
structural_variation
structural_variation_id variation_name  alias source_id study_id  class_attrib_id clinical_significance validation_status is_evidence somatic copy_number
11769438  essv4488280 NULL  11  4465  286 NULL  NULL  1 1 NULL
11769459  essv4489263 NULL  11  4465  286 NULL  NULL  1 1 NULL
11769608  essv6661646 NULL  11  4465  289 NULL  NULL  1 1 NULL
11769636  essv4489159 NULL  11  4465  211 NULL  NULL  1 1 NULL
11776239  esv1914296  COST16848 11  4465  211 NULL  NULL  0 1 NULL

study_id 4465
study_id  source_id name  description url external_reference  study_type
4465  11  estd192 Catalogue of Somatic Mutations in Cancer (COSMIC) version 61  ftp://ftp.ebi.ac.uk/pub/databases/dgva/estd192_COSMIC http://cancer.sanger.ac.uk/cancergenome/projects/cosmic/  Somatic

my $sva = $registry->get_adaptor("human", "variation", "structuralvariation");
my $svpfa = $registry->get_adaptor("human","variation","structuralvariationpopulationfrequency");
my $svfa = $registry->get_adaptor("human", "variation", "structuralvariationfeature");
my $sa =  $registry->get_adaptor("human", "core", "slice");
my $slice = $sa->fetch_by_region('chromosome', 7, 140424943, 140624564);
my $svs = $svfa->fetch_all_by_Slice_SO_term($slice, '');
print scalar @$svs, "\n";
=end
=cut
