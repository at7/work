use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Slice qw(split_Slices);
use FileHandle;


my $registry = 'Bio::EnsEMBL::Registry';

my $file = '/hps/nobackup/production/ensembl/anja/release_90/ensembl.registry.sheep';

$registry->load_all($file);

my $species = 'sheep';

my $vfa = $registry->get_adaptor($species, 'variation', 'variationfeature');
my $vdba = $registry->get_DBAdaptor($species, 'variation');
my $sa = $registry->get_adaptor($species, 'core', 'slice');

my $dbh = $vdba->dbc->db_handle;

my $toplevel_slices = $sa->fetch_all('chromosome');
my $seq_region_ids = {};
my $vf_counts = {};


foreach my $toplevel_slice (@$toplevel_slices) {
  
  $seq_region_ids->{$toplevel_slice->get_seq_region_id} = $toplevel_slice->seq_region_name;
  my $seq_region_id = $toplevel_slice->get_seq_region_id;
  my $seq_region_name = $toplevel_slice->seq_region_name;
  my $sth = $dbh->prepare(qq/select count(*) from variation_feature where seq_region_id=$seq_region_id and display = 1;/);
  $sth->execute() or die $sth->errstr;
  my $count = $sth->fetchrow_arrayref->[0];
  $vf_counts->{$seq_region_name} = $count;
  $sth->finish;
}

=begin
foreach my $toplevel_slice (@$toplevel_slices) {
  my $seq_region_id = $toplevel_slice->get_seq_region_id;
  my $seq_region_name = $toplevel_slice->seq_region_name;
  my $fh = FileHandle->new("/hps/nobackup/production/ensembl/anja/release_90/sheep/dumps/$seq_region_name.txt", 'w');
  my $sth = $dbh->prepare(qq/select variation_name from variation_feature where seq_region_id=$seq_region_id and display = 1;/);
  $sth->execute() or die $sth->errstr;
  while (my $row = $sth->fetchrow_arrayref) {
    my $name = $row->[0];
    print $fh $name, "\n";
  }
  $sth->finish;
}
=end
=cut

#my @split_sizes = (1e3, 1e4, 1e6);



my $global_split_size = 5e5;
my @split_sizes = (1e3);

my $overlap = 1;
my $counts = {};
my $duplicated = {};

foreach my $seq_region_id (keys %$seq_region_ids) { 
  my $slice = $sa->fetch_by_seq_region_id($seq_region_id);
  my $seq_region_name = $seq_region_ids->{$seq_region_id};
  next unless ("$seq_region_name" eq '24');

  foreach my $split_size (@split_sizes) {
#    my $fh = FileHandle->new("/hps/nobackup/production/ensembl/anja/release_90/sheep/split_dumps/$seq_region_name\_$split_size.txt", 'w');
    my $vf_count = 0;
    my $global_pieces = split_Slices([$slice], $global_split_size, $overlap);
    foreach my $global_slice (@$global_pieces) {
      print STDERR $global_slice->length, ' ', $global_slice->end, ' ', $global_slice->seq_region_end, "\n";
      next;

      my $slice_pieces = split_Slices([$global_slice], $split_size, $overlap);
      foreach my $slice_piece (@$slice_pieces) {
        my $slice_piece_start = $slice_piece->seq_region_start;
        my $slice_piece_end = $slice_piece->seq_region_end;
        # if slice_piece_end == $slice->length... extend slice_piece_end to include all remaining variants
        my $included = {};
        my $vfs = $vfa->fetch_all_by_Slice($slice_piece);
        foreach my $vf (@$vfs) {
          my $vf_start = $vf->seq_region_start;
          my $vf_end = $vf->seq_region_end;
          my $variant_name = $vf->variation_name;

          if ($vf_end < $vf_start) {
            ($vf_start, $vf_end) = ($vf_end, $vf_start);
          } 
          if ($vf_start >= $slice_piece_start) {
            next if ($vf_start == $slice_piece_end && $vf_end >= $slice_piece_end);
            if ($duplicated->{$variant_name}) {
              print STDERR "duplicatced $seq_region_name $slice_piece_start $slice_piece_end $vf_start $vf_end $variant_name\n";
            } else {
              $included->{$variant_name} = 1;
#              print $fh $variant_name, "\n"; 
              $vf_count++;
            }
          } else { 
            if (!$duplicated->{$variant_name}) {
              print STDERR "missing $seq_region_name $slice_piece_start $slice_piece_end $vf_start $vf_end $variant_name\n";
            }
          }
        } # end slice piece

        $duplicated = $included;
      }
    } # end global slice
    my $sql_count = $vf_counts->{$seq_region_name};
    print STDERR ">>>$seq_region_name $split_size $vf_count $sql_count\n";
#    $fh->close();
  }
}
