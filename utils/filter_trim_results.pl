use strict;
use warnings;


use FileHandle;

my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/ExAC/multi_allelic_after_trim_evdn', 'r');

#2       241696840       241696852       ATCCTCCTCCTCC/ATCCTCCTCC        .       241696850       241696852       TCC/-   0       \N      \N      \N
#2       241696840       241696852       ATCCTCCTCCTCC/ATCCTCCTCC        .       241696841       241696843       TCC/-   1       rs10594016      TCC/-   Frequency,1000Genomes,ExAC

my $lookup = {};
my $variant_ids = {};
while (<$fh>) {
  chomp;
  my ($vcf_chrom, $vcf_start, $vcf_end, $vcf_alleles, $vcf_id, $trim_start, $trim_end, $trim_alleles, $end_first, $matched_id, $matched_alleles, $matched_evdn) = split/\t/;

#  my $key = "$vcf_chrom $vcf_start $vcf_end $vcf_alleles";
  my $key = "$vcf_chrom $vcf_start $vcf_end";

  my $trim_order = 'start_first';
  if ($end_first) {
    $trim_order = 'end_first';
  }

  $lookup->{$key}->{$trim_order}->{$matched_id} = "$matched_alleles $matched_evdn";

#  if ($matched_id =~ /^rs/) {
#    $variant_ids->{$matched_id} = "$vcf_chrom $trim_start $trim_end $matched_alleles";
#    $variant_ids->{$matched_id} = 1;
#  }
 
}

$fh->close();

foreach my $key (keys %$lookup) {
  my @ids = keys %{$lookup->{$key}->{end_first}};
  my @rsids = grep {$_ =~ /^rs/} @ids;
  if (scalar @rsids > 1) {
    print STDERR $key, ' ', join(', ', @rsids), "\n";
  }

}


#my $fh_out = FileHandle->new('/hps/nobackup/production/ensembl/anja/ExAC/compare_trim_results', 'w');
#foreach my $variant_id (keys %$variant_ids) {
#  print $fh_out $variant_ids->{$variant_id}, "\n";
#}

#$fh_out->close;

#foreach my $key (keys %$lookup) {
#  my $start_first_keys = join(',', sort keys %{$lookup->{$key}->{start_first}});
#  my $end_first_keys = join(',', sort keys %{$lookup->{$key}->{end_first}});
#  print $fh_out "$key $start_"

#  if ($start_first_keys ne $end_first_keys) {
#    print STDERR "$key $start_first_keys $end_first_keys\n";
#  }
#}
#$fh_out->close;



