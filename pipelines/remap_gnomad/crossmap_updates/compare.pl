use strict;
use warnings;


use FileHandle;

my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/gnomad/crossmap_updates/exome_chr1_tests/gnomad_exomes_chr1_fixed.txt', 'r');

my $hash = {};

while (<$fh>) {
    chomp;
#18      10023   10023   T       A       rs148696862     dbSNP_151;TSA=SNV;E_Freq;E_TOPMed;E_gnomAD
    my ($chr, $start, $end, $ref, $alts, $id, $info) = split/\t/;
    my $key = "$chr-$start-$end-$id-$ref";
    foreach my $alt (split/,/, $alts) {
        $hash->{$key}->{$alt} = 1;
    }
}


$fh->close;


$fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/gnomad/crossmap_updates/exome_chr1_tests/gnomad_exomes_chr1_errors.txt', 'r');

while (<$fh>) {
    chomp;
#18      80247374        80247374        G       C       rs553791563
    my ($chr, $start, $end, $ref, $alt, $id, $info) = split/\t/;
    my $key = "$chr-$start-$end-$id-$ref";
    if (!defined $hash->{$key}->{$alt}) {
        print STDERR join("\t", $chr, $start, $end, $ref, $alt, $id), "\n";
        foreach my $error_alt (keys %{$hash->{$key}}) {
            print STDERR "    $error_alt\n"; 
        }
    }
}
$fh->close;



print scalar keys %$hash, "\n";
