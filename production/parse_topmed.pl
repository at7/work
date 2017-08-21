use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;
use Bio::EnsEMBL::IO::Parser::VCF4;
use Bio::EnsEMBL::Registry;

#my $vcf_file = "/nfs/production/panda/ensembl/variation/data/dbSNP/VCF/All_20170403.vcf.gz";
my $vcf_file = "/nfs/production/panda/ensembl/variation/data/dbSNP/VCF/All_20170403.GRCh37_CrossMap.vcf.gz";

#my $fh_out = FileHandle->new("/hps/nobackup/production/ensembl/anja/topmed_cross_map", 'w');

my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($vcf_file);

# seq_region ids

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -port => 3337,
);

my $species = 'homo_sapiens';

my $slice_adaptor = $registry->get_adaptor($species, 'core', 'slice');

my $seq_region_ids = {};

for my $chrom (1..22, 'X', 'Y', 'MT') {
  my $slice = $slice_adaptor->fetch_by_region('chromosome', $chrom); 
  my $seq_region_id = $slice->get_seq_region_id;
  $seq_region_ids->{$chrom} = $seq_region_id;
}

for my $chrom (1..22, 'X', 'Y', 'MT') {
  my $seq_region_id = $seq_region_ids->{$chrom};
  my $fh_out = FileHandle->new("/hps/nobackup/production/ensembl/anja/dbSNP150/$chrom", 'w');
  $parser->seek($chrom, 1);
  while ($parser->next) {
    my $info = $parser->get_info;
    my $dbSNPBuildID = $info->{dbSNPBuildID};
    next unless ($dbSNPBuildID == 150);
    my $topmed = $info->{TOPMED};
    if (!$topmed) {
      my $ref = $parser->get_reference;
      my $vcf_alt = $parser->get_alternatives;
      my $start = $parser->get_start;
      my @ids = @{$parser->get_IDs};
      if (scalar @ids != 1) {
        print STDERR join(', ', @{$parser->get_IDs}), "\n";
      }
      my $id = $ids[0];

      my $alt = join(',', @$vcf_alt);

      my $vcf_alleles = "$ref/" . join('/', @$vcf_alt);

      my $is_indel = 0;
      foreach my $alt_allele(split ',', $alt) {
        $is_indel = 1 if $alt_allele =~ /^[DI]/;
        $is_indel = 1 if length($alt_allele) != length($ref);
      }

      if($alt =~ /\,/) {
        if($is_indel) {
          my @alts;
          # find out if all the alts start with the same base
          # ignore "*"-types
          my %first_bases = map {substr($_, 0, 1) => 1} grep {!/\*/} ($ref, split(',', $alt));

          if(scalar keys %first_bases == 1) {
            $ref = substr($ref, 1) || '-';

            foreach my $alt_allele(split ',', $alt) {
              $alt_allele = substr($alt_allele, 1) unless $alt_allele =~ /\*/;
              $alt_allele = '-' if $alt_allele eq '';
              push @alts, $alt_allele;
            }
          }
          else {
            push @alts, split(',', $alt);
          }
          $alt = join "/", @alts;
        } else {
          # for substitutions we just need to replace ',' with '/' in $alt
          $alt =~ s/\,/\//g;
        }
      }
      elsif($is_indel) {
        # insertion or deletion (VCF 4+)
        if(substr($ref, 0, 1) eq substr($alt, 0, 1)) {
          # chop off first base
          $ref = substr($ref, 1) || '-';
          $alt = substr($alt, 1) || '-';
        }
      }
      my $end = ($start + length($ref)) - 1;
      if ($ref eq '-') {
        $end--;
      }
      print $fh_out join("\t", $id, $seq_region_id, $start, $end, "$ref/$alt"), "\n";
    }
  }
  $fh_out->close;
}

