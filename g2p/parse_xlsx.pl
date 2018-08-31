use strict;
use warnings;

use Spreadsheet::Read;
#use Spreadsheet::ParseXLSX;
my $file = '/hps/nobackup2/production/ensembl/anja/G2P/skin/G2P Skin update 180618.xlsx';
my $book  = ReadData($file);
my $sheet = $book->[1];
my @rows = Spreadsheet::Read::rows($sheet);
foreach my $row (@rows) {
  print $row->[0], "\n";
}

