use strict;
use warnings;

use FileHandle;

my $dir = '/hps/nobackup2/production/ensembl/anja/vep_data/output/grch37/';

my $fh_not_in_new = FileHandle->new("cmp_vep_refseq_cache_not_in_new", 'w');
my $fh_not_in_prev = FileHandle->new("cmp_vep_refseq_cache_not_in_prev", 'w');
my $fh_different_values = FileHandle->new("cmp_vep_refseq_cache_different_values", 'w');
my $previous_release = file2hash("$dir/vep_cache_test_95_37_refseq.out");
my $new_release = file2hash("$dir/vep_cache_test_96_37_refseq.out");
#vep_cache_test_96_38_refseq.out
# not anymore in new release
foreach my $key (keys %$previous_release) {
  foreach my $snd_key (keys %{$previous_release->{$key}}) {
    if (!defined $new_release->{$key}) {
      print $fh_not_in_new "$key not in new release\n";
      next;
    }
    if (!defined $new_release->{$key}->{$snd_key}) {
      print $fh_not_in_new "$snd_key not in new release $key\n";
      next;
    }
  }
}
$fh_not_in_new->close();

# not in previouse release
foreach my $key (keys %$new_release) {
  foreach my $snd_key (keys %{$new_release->{$key}}) {
    if (!defined $previous_release->{$key}) {
      print $fh_not_in_prev "$key not in previous release\n";
      next;
    }
    if (!defined $previous_release->{$key}->{$snd_key}) {
      print $fh_not_in_prev "$snd_key not in previous release $key\n";
      next;
    }
  }
}
$fh_not_in_prev->close();

# different values
foreach my $key (keys %$new_release) {
  foreach my $snd_key (keys %{$new_release->{$key}}) {
    if (!defined $previous_release->{$key}) {
      next;
    }
    if (!defined $previous_release->{$key}->{$snd_key}) {
      next;
    }
    my $old_value = $previous_release->{$key}->{$snd_key}; 
    my $new_value = $new_release->{$key}->{$snd_key};
    if ($old_value ne $new_value) {
      print $fh_different_values "Different value for $key: $snd_key: $old_value $new_value\n";
    }
  }
}
$fh_different_values->close();

sub file2hash {
  my $file = shift;
  my $hash = {};
#Uploaded_variation Location  Allele  Gene  Feature Feature_type  Consequence cDNA_position CDS_position  Protein_position  Amino_acids Codons  Existing_variation  Extra
#rs772603749 12:63042271 G ENSG00000111110 ENST00000228705 Transcript
  my $fh = FileHandle->new($file, 'r');
  while (<$fh>) {
    chomp;
    my @values = split("\t");
    my $Uploaded_variation = $values[0] || 'Uploaded_variation';
    my $Location = $values[1] || 'Location';
    my $Allele = $values[2] || 'Allele';
    my $Gene = $values[3] || 'Gene';
    my $Feature = $values[4] || 'Feature';
    my $key = join("_", $Uploaded_variation, $Location, $Allele, $Gene, $Feature);
    if (defined $values[13]) {
      foreach my $extra (split(';', $values[13])) {
        if ($extra =~ /=/) {
          my ($snd_key, $value) = split/=/, $extra;
          $hash->{$key}->{$snd_key} = $value;
        } else {
          $hash->{$key}->{$extra} = 1;
        }
      }
    }
  }
  $fh->close;
  return $hash;
}
