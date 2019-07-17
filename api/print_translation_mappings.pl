use strict;
use warnings;
use Digest::MD5 qw(md5_hex);
use Bio::EnsEMBL::Registry;
use FileHandle;


if (eval { require Bio::EnsEMBL::XS; 1 }) {
  print STDERR "XS is installed\n";
}
my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all('/hps/nobackup2/production/ensembl/anja/release_98/human/ensembl.registry');

my $fh = FileHandle->new("/hps/nobackup2/production/ensembl/anja/release_98/human/translation_md5s_16_e97", 'w');

my @transcripts = ();
my $sa = $registry->get_adaptor('homo_sapiens', 'core', 'slice');
my $include_lrg = 1;
my $slice = $sa->fetch_by_region('chromosome', 16);
#for my $slice (@{ $sa->fetch_all('toplevel', undef, 1, undef, ($include_lrg ? 1 : undef)) }) {
   
  for my $gene (@{ $slice->get_all_Genes(undef, undef, 1) }) {
    for my $transcript (@{ $gene->get_all_Transcripts }) {
      if (my $translation = $transcript->translation) {
#        print $fh ">>", $transcript->translation, "\n";
        push @transcripts, $transcript;
      }
    }
  }
#}

for my $tran (@transcripts) {
  my $tl = $tran->translation;
  my $seq = $tl->seq;
#  my $md5 = md5_hex($seq);
  print $fh $tl->stable_id, "\n";
}
$fh->close;

