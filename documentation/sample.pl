use strict;
use warnings;


=begin
# All the wonderful things we can do with our new sample schema

- An individual can have multiple samples
- One sample is associated with one individual
- The name for individual and a sample for this individual can be different

- creat a new sample:
  - pass the individual object to sample constructor
  - if creating a new sample object always require an individual object or id, 
    if no indiviual information is available creat a new individual object before
    creating the sample object

- Store: display, has_coverage, variation_set_id on sample level
- Store: gender, mother_individual_id, father_individual_id, individual_type_id on individual level


- store synonyms for a sample
- associate a study with genotypes for a sample

# Rewrite:
# VCFCollection
# StructuralVariationSample.pm


=end
=cut

my $individual_adaptor;
my $sample_adaptor;

# additional attributes: source, url, external_reference, study_type
my $study_1000G = Bio::EnsEMBL::Variation::Study->new(
  -name => '1000G phase 3',
  -description => 'Whole-genome sequencing',
);

my $study_ExAC = Bio::EnsEMBL::Variation::Study->new(
  -name => 'Exome Aggregation Consortium',
  -description => 'exome sequencing',
);

my $individual = Bio::EnsEMBL::Variation::Individual(
  -name => 'NA18967', 
);
$individual = $individual_adaptor->store($individual); 

my $sample_1000G = Bio::EnsEMBL::Variation::Sample->new(
  -individual => $individual,
  -study => $study,
);
$sample_adaptor->store($sample);


# OR:
$individual->add_Sample->($sample);
$individual_adaptor->store($individual);




