use strict;
use warnings;

use FileHandle;
use Data::Dumper;
use DateTime::Format::Strptime;

my $release_runs =  {
  93 => ['93/hc_93_human_final.err'],
  95 => [
    '95/human_95_38.err',
    '95/human_95_38_r3.err',
    '95/human_95_38_tVFK.err',
    '95/human_95_38_tVFK.err',
  ],
  96 => [
    '96/human_96_CmpPrevConseq.err',
    '96/human_96_EmptyVariationTables.err',
    '96/human_96_fail_rerun.err',
    '96/human_96_pass_b1.err',
    '96/human_96_pass_b2.err',
    '96/human_96_pass_b3.err',
    '96/human_96_review.err',
  ],
  97 => [
    '97/HC_human_97_38.err',
    '97/HC_human_constype_97_38.err'
  ],
  98 => [
    '98/human98_timings_incomplete_29072019.err',
    '98/human/first_round/human_98_chunk1.err',  
    '98/human/first_round/human_98_chunk2.err',  
    '98/human/first_round/human_98_chunk3.err',  
    '98/human/first_round/human_98_chunk5.err',  
    '98/human/first_round/human_98_chunk6.err',  
    '98/human/first_round/human_98_chunk7.err',  
    '98/human/first_round/human_98_tv.err',  
  ],
};

my $summary = {};

foreach my $release (keys %$release_runs) {
  my @files = @{$release_runs->{$release}};
  foreach my $file (@files) {
    write_release_runtimes($release, $file);
  }
}
my $fh = FileHandle->new('HC_runtimes.txt', 'w');
print $fh "Testcase\t", join("\t", qw/93 95 96 97 98/), "\n";
foreach my $test (sort keys %$summary) {
    print $fh $test;
  foreach my $release (qw/93 95 96 97 98/) {
    my @times = keys %{$summary->{$test}->{$release}};
    if (scalar @times > 0) {
      print $fh "\t", join(',', @times);
    } else {
      print $fh "\tNA";
    }
  }
  print $fh "\n";
}
$fh->close;
sub write_release_runtimes {
  my $release = shift;
  my $file = shift;
  my $fh = FileHandle->new('/nfs/production/panda/ensembl/variation/healthchecks/' . $file, 'r');
  my $timestamp = '';
  my $start_end_times = {};
  while (<$fh>) {
    chomp;
    if (is_timestamp($_)) {
      $timestamp = get_timestamp($_);
    } elsif (/Completed/ || /INFO: org\.ensembl/) {
      my $test = get_completed_test($_);
      $start_end_times->{$test}->{end} = $timestamp;
    } elsif (/Executing/ || /Starting/) {
      my $test = get_started_test($_);
      $start_end_times->{$test}->{start} = $timestamp;
    }
  }

  $fh->close;

  my $format = DateTime::Format::Strptime->new(
     pattern   => '%Y-%m-%d-%l-%M-%S-%p',
     time_zone => 'local',
     on_error  => 'croak',
  );

  foreach my $test (sort keys %$start_end_times) {
    my $start = $start_end_times->{$test}->{start};
    my $end = $start_end_times->{$test}->{end};
    next unless ($start && $end);
    my $dt = $format->parse_datetime($start);
    my $dt2 = $format->parse_datetime($end);
    my $diff = $dt2 - $dt;
    my ( $days, $hours, $minutes ) = $diff->in_units('days', 'hours', 'minutes');
    $summary->{$test}->{$release}->{$days."d:".$hours."h:".$minutes."m"} = 1;
  }
}
sub is_timestamp {
  my $line = shift;
# Jul 31, 2019 6:22:32 PM 
  return ($line =~ m/([A-z]+)\s(\d+),\s(\d+)\s(\d*:\d*:\d*)\s([A-z]+).*/);

}

sub get_timestamp {
  my $line = shift;
  my $month_number = {
    'Jan' => 1,
    'Feb' => 2,
    'Mar' => 3,
    'Apr' => 4,
    'May' => 5,
    'Jun' => 6,
    'Jul' => 7,
    'Aug' => 8,
    'Sep' => 9,
    'Oct' => 10,
    'Nov' => 11,
    'Dec' => 12,
  };
# Jul 30, 2019 3:19:22 AM  => 2019-07-30-3-19-22-AM
  if ($line =~ m/([A-z]+)\s(\d+),\s(\d+)\s(\d*):(\d*):(\d*)\s([A-z]+).*/) {
    
    my $month =  $month_number->{$1}; 
    my $day = $2;
    my $year = $3;
    my $h = $4;
    my $m = $5;
    my $s = $6;
    my $am_pm = $7;

    return "$year-$month-$day-$h-$m-$s-$am_pm";
  }
}

sub get_started_test {
  my $line = shift;
  # INFO: Executing org.ensembl.healthcheck.testcase.variation.ComparePreviousVersionPhenotypeFeatures on homo_sapiens_variation_98_38
  # INFO: Starting test org.ensembl.healthcheck.testcase.variation.ForeignKeyCoreId
    $line =~ m/.*[Executing|Starting test] org\.ensembl\.healthcheck\.[A-z]+\.[A-z]+\.([A-z]+)\s.*/;
    return $1;
}
sub get_completed_test {
  my $line = shift;
# Completed executing org.ensembl.healthcheck.testcase.variation.ComparePreviousVersionVariationSets on homo_sapiens_variation_98_38
# Completed executing org.ensembl.healthcheck.testcase.generic.SchemaType on homo_sapiens_variation_98_38
# INFO: org.ensembl.healthcheck.testcase.variation.ForeignKeyCoreId PASSED
  if ($line =~ /Completed/) {
    $line =~ m/.*Completed executing org\.ensembl\.healthcheck\.[A-z]+\.[A-z]+\.([A-z]+)\s.*/;
    return $1;
  }
  $line =~ m/INFO: org\.ensembl\.healthcheck\.[A-z]+\.[A-z]+\.([A-z]+)\s.*/;
  return $1;

}
