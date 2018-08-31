use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Utils::Slice qw(split_Slices);

use Digest::MD5 qw(md5_hex);

use FileHandle;

my $fh = FileHandle->new('/hps/nobackup2/production/ensembl/anja/release_94/human/protein_function/all_translations', 'w');

my $registry = 'Bio::EnsEMBL::Registry';

my $file = '/hps/nobackup2/production/ensembl/anja/release_94/human/protein_function/ensembl.registry';

$registry->load_all($file);

my $species = 'human';

my  @transcripts = ();

my $sa = $registry->get_adaptor($species, 'core', 'slice');
my $include_lrg = 1;
for my $slice (@{ $sa->fetch_all('toplevel', undef, 1, undef, ($include_lrg ? 1 : undef)) }) {
  for my $gene (@{ $slice->get_all_Genes(undef, undef, 1) }) {
    for my $transcript (@{ $gene->get_all_Transcripts }) {
      if (my $translation = $transcript->translation) {
        push @transcripts, $transcript;
      }
    }
  }
}

$sa = $registry->get_adaptor($species, 'otherfeatures', 'slice');
my $slices = $sa->fetch_all('toplevel', undef, 1, undef, undef);
for my $slice (@{$slices}) {
  for my $gene (@{ $slice->get_all_Genes(undef, undef, 1) }) {
    for my $transcript (grep {$_->stable_id =~ /^NM_/} @{ $gene->get_all_Transcripts }) {
      if (my $translation = $transcript->translation) {
        push @transcripts, $transcript;
      }
    }
  }
}


for my $tran (@transcripts) {
  my $tl = $tran->translation;
  my $seq = $tl->seq;
  my $md5 = md5_hex($seq);
  print $fh $tran->stable_id, ' ', $tl->stable_id, ' ', $md5, "\n";
}

