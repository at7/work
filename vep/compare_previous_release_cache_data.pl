use strict;
use warnings;

use FileHandle;

my $dir = '/hps/nobackup2/production/ensembl/anja/vep_data/output/grch37/';


my $previous_release = file2hash("$dir/production_test_95_37.out");
my $new_release = file2hash("$dir/production_test_37.out");

foreach my $key (keys %$new_release) {
  foreach my $pop (keys %{$new_release->{$key}}) {
    if (!exists $previous_release->{$key}) {
      print STDERR "Key doesn't exist in prev $key\n";
    } else {
      if (!exists $previous_release->{$key}->{$pop}) {
        print STDERR "Pop $pop dosen't exist for $key\n";
      } else {
        my $old_af = $previous_release->{$key}->{$pop};
        my $new_af = $new_release->{$key}->{$pop};
        if ($old_af == $new_af) {
          next if ($old_af == 0);
          print STDERR "=====$key $pop $old_af $new_af\n";
        }
        if ($old_af == 0) {
          print STDERR "$key $pop $old_af $new_af\n";
          next;
        }
        my $increase = $new_af - $old_af;
        my $precent_increase = ($increase/$old_af) * 100;
        print STDERR "$key $pop $old_af $new_af $precent_increase\n";
      }
    }
  }
}


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
      my @extra = split(';', $values[13]);
      foreach (@extra) {
        if (/^gnomAD/) {
          my ($pop, $freq) = split(/=/);
          $hash->{$key}->{$pop} = $freq;
        }
      }
    }
  }
  $fh->close;
  return $hash;
}
