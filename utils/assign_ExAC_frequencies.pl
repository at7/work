use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::Variation::Utils::Sequence qw(get_3prime_seq_offset trim_sequences);
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::IO::Parser::VCF4Tabix;


my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
  -host => 'ensembldb.ensembl.org',
  -user => 'anonymous',
  -port => 3337,
  -DB_VERSION => 89,
);

if (1) {
my $species = 'human';
my $vfa = $registry->get_adaptor($species, 'variation', 'variationfeature');
my $va = $registry->get_adaptor($species, 'variation', 'variation');

my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/ExAC/end_first_matched_variant_ids', 'r');
my $log = FileHandle->new('/hps/nobackup/production/ensembl/anja/ExAC/assign_exac_freq_to_end_first_match_28_07_2017', 'w');


my $exac_file = '/hps/nobackup/production/ensembl/anja/ExAC/ExAC.r1.sites.vep.vcf.gz';


my $prefix = 'ExAC';
my $config = {};
$config->{file} = $exac_file;

my $assign_frequency = 0;

#freq_vcf => [
# {
#   file => $self->o('data_dir').'/ExAC.0.3.GRCh37.vcf.gz',
#   pops => ['', qw(AFR AMR Adj EAS FIN NFE OTH SAS)],
#   name => 'ExAC',
#   prefix => 'ExAC',
#   version => 0.3,
# },
#],

get_header_info($config);
run($config);

sub run {
  my $self = shift;
  my $parser = Bio::EnsEMBL::IO::Parser::VCF4Tabix->open($exac_file);

  while (<$fh>) {
    chomp;
    my @ids = split/,/;
    foreach my $id (@ids) {
      next unless ($id =~ /^rs/);
      my $variation = $va->fetch_by_name($id);
      next unless $variation;
      my $vfs = $variation->get_all_VariationFeatures;
      if (scalar @$vfs > 1) {
        print $log "$id has more than one variation feature\n";
        next;
      }
      my $data = {};
      my $vf = $vfs->[0];
      my $vf_start = $vf->seq_region_start;
      my $vf_end = $vf->seq_region_end;
      my $vf_allele_string = $vf->allele_string;
      my @vf_alleles = split('/', $vf->allele_string);

      $parser->seek($vf->seq_region_name, $vf_start - 1, $vf_end + 1);
      my $count_results = 0;
      while($parser->next) {
        print $log "$id parser next\n";
        my $orig_ref = $parser->get_reference;
        my $orig_start = $parser->get_raw_start;
        my @orig_alts = @{$parser->get_alternatives};
        my @vcf_alleles = @{$parser->get_alternatives};
        my $ref_allele = $orig_ref;

        my $alts_by_start = {};

        foreach my $alt_index(0..$#orig_alts) {
          my $orig_alt = $orig_alts[$alt_index];
          my ($ref, $alt, $start) = @{trim_sequences($orig_ref, $orig_alt, $orig_start, undef, 1, 1)};
          print $log "VF: $id $vf_start $vf_end $vf_allele_string VCF: $orig_ref/". join('/', @orig_alts), " After trim: $ref/$alt $start\n";

          push @{$alts_by_start->{$start}}, {
            r => $ref,
            a => $alt,
            i => $alt_index        
          };
        }

        foreach my $start (sort {$a <=> $b} keys %$alts_by_start) {
          my $hashes = $alts_by_start->{$start};
          my $ref = $hashes->[0]->{r};                                  # ref should be the same for all
          my @alts = map {$_->{a}} @$hashes;
          my %alt_indexes = map {$_->{i} => $_->{a}} @$hashes;
          my %alt2index = map {$_->{a} => $_->{i}} @$hashes;
          while( my( $key, $value ) = each %alt2index ){
            print $log "Alt2index $key: $value\n";
          }


          my @sorted_alt_indexes = sort {$a <=> $b} keys %alt_indexes;

          # alt to index
          my @selected_indexes = ();
          foreach my $vf_allele (@vf_alleles) {
            if ($alt2index{$vf_allele}) {
              push @selected_indexes, $alt2index{$vf_allele};
            }
          }
          print $log "Selected indexes for frequency selection ", join(', ', @selected_indexes), "\n";
          # go through variant allels and pick frequency from VCF allele
          
        }


        if ($assign_frequency) {
          my $info = $parser->get_info;
          foreach my $pop (qw(AFR AMR Adj EAS FIN NFE OTH SAS)) {
            print $log "Population $pop\n";
            my $info_prefix = '';
            my $info_suffix = '';

            # have to process ExAC differently from 1KG and ESP
            $info_suffix = '_'.$pop if $pop;

            my $store_name = $prefix.$pop;

            $store_name =~ s/\_$//;
            
  #          print $log $info_prefix.'AF'.$info_suffix, "\n";
  #          print $log $info_prefix.'AN'.$info_suffix, "\n";
  #          print $log $info_prefix.'AC'.$info_suffix, "\n";


          
            if(exists($info->{$info_prefix.'AF'.$info_suffix})) {
              my $f = $info->{$info_prefix.'AF'.$info_suffix};
              print $log "$f\n";
              my @split = split(',', $f);

              # there will be one item in @split for each of the original alts
              # since we may not be dealing with all the alts here
              # we have to use the indexes and alts we logged in %alt_indexes
  #            my $tmp_f = join(',',
  #              map {$alt_indexes{$_}.':'.($split[$_] == 0 ? 0 : sprintf('%.4g', $split[$_]))}
  #              grep {looks_like_number($split[$_])}
  #              @sorted_alt_indexes
  #            );

  #            $v->{$store_name} = $tmp_f if defined($tmp_f) && $tmp_f ne '';
            }
            elsif(exists($info->{$info_prefix.'AC'.$info_suffix})) {
              my $c = $info->{$info_prefix.'AC'.$info_suffix};
              print $log "AC $c\n";
              my $n = $info->{$info_prefix.'AN'.$info_suffix};
              print $log "AN $n\n";
              my @split = split(',', $c);

              unless($n) {
                $n += $_ for @split;
              }
            }
          } # end population loop
        } # end of frequency

      }
      if (!$count_results) {
        print $log "No data for $id\n";
      }

    }
  }
  $fh->close;
  $log->close;
}

sub get_header_info {
  my $self = shift;
  
  if(!exists($self->{header_info})) {
    open IN, "tabix -f -h " . $self->{file}. " 1:1-1 |";
    
    my %headers = ();
    my @lines = <IN>;
    
    while(my $line = shift @lines) {
      if($line =~ /ID\=AC(\_[A-Zdj]+)?\,.*\"(.+)\"/) {
        my ($pop, $desc) = ($1, $2);
        
        $desc =~ s/Counts?/frequency/i;
        $pop ||= '';
        
        my $field_name = 'ExAC_AF'.$pop;
        $headers{$field_name} = 'ExAC '.$desc;

        if ($self->{display_ac}){
          $field_name = 'ExAC_AC'.$pop;
          $headers{$field_name} = 'ExAC'.$pop.' Allele count';
        }
        if ($self->{display_an}){
          $field_name = 'ExAC_AN'.$pop;
          $headers{$field_name} = 'ExAC'.$pop.' Allele number';
        }
        push @{$self->{headers}}, 'AC'.$pop;
      }
    }
    
    close IN;
    
    die "ERROR: No valid headers found in ExAC VCF file\n" unless scalar keys %headers;
    
    $self->{header_info} = \%headers;
  }
  
  return $self->{header_info};
}

}




if (1) {
my $fh = FileHandle->new('/hps/nobackup/production/ensembl/anja/ExAC/different_trim_results', 'r');
#my $fh_out = FileHandle->new('/hps/nobackup/production/ensembl/anja/ExAC/start_first_matched_variant_ids', 'w');
 
#11 111989990 111989992 ATT/ATTTTT \N rs776645305 

my ($count_start_first, $count_end_first, $count_both_match);
while (<$fh>) {
  chomp;
  my ($chrom, $vcf_start, $vcf_end, $vcf_alleles, $start_first_match, $end_first_match) = split/\s/;
  if ($start_first_match eq '\N' && $end_first_match ne '\N') {
#    print $fh_out "$end_first_match\n";
    $count_end_first++;
  } elsif ($end_first_match eq '\N' && $start_first_match ne '\N') {
#    print $fh_out $start_first_match, "\n";
    $count_start_first++;
  } else {
    $count_both_match++;
  }
}

$fh->close;
#$fh_out->close;
print "Start first match $count_start_first, End first match $count_end_first, Both match $count_both_match\n";
}

