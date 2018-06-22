use strict;
use warnings;

use JSON;
use FileHandle;
use Data::Dumper;
$Data::Dumper::Indent = 1;

my $json = JSON->new();
my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/vep_data/output/homo_sapiens_GRCh38_test_output.json', 'r');
my $qc_dir = '';

my $has_var = 1;

while(<$fh>) {
  chomp;
    my $data = $json->decode($_);

    print "ERROR: input field not found in JSON output\nQC dir: $qc_dir\n".(Dumper $data)."\n\n" unless $data->{input};
    my @input = split("\t", $data->{input});

    my $feature_type = $input[-1];
    my $expected_cons = join(",", sort split(",", $input[-2]));
    my $feature_id = $input[-3];

    # check consequence type
    print "ERROR: no data for $feature_type found in JSON output\nQC dir: $qc_dir\n".(Dumper $data)."\n\n" unless $data->{$feature_type.'_consequences'};

    if(
      my ($blob) = grep {
        # motif_feature stable_id from DB is the regfeat ID, annoyingly
        $feature_type eq 'motif_feature' ? 1 : $_->{$feature_type.'_id'} eq $feature_id
      } @{$data->{$feature_type.'_consequences'}}
    ) {
      print "ERROR: no consequence_terms field in blob\nQC dir: $qc_dir\n".(Dumper $data)."\n\n" unless $blob->{consequence_terms};
      my $got_cons = join(",", sort @{$blob->{consequence_terms}});
      print "ERROR: consequence_types don't match, expected: $expected_cons, got: $got_cons\nQC dir: $qc_dir\n".(Dumper $data)."\n\n" unless $expected_cons eq $got_cons;
    }
    else {
      print "ERROR: no data for $feature_id found in JSON output\nQC dir: $qc_dir\n".(Dumper $data)."\n\n";
    }

    # check colocated variants
    if($has_var) {
      my $expected_var_id = $input[-4];
      print "ERROR: no data for colocated_variants found in JSON output\nQC dir: $qc_dir\n".(Dumper $data)."\n\n" unless $data->{colocated_variants};

      print "ERROR: expected var id $expected_var_id not found\nQC dir: $qc_dir\n".(Dumper $data)."\n\n"
        unless grep {$_->{id} eq $expected_var_id} @{$data->{colocated_variants}};
    }
  }
