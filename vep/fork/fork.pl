use strict;
use warnings;
use strict;

use IO::Socket;
use IO::Select;


my $fork_number = 5;
my $buffer_size = 100;
my $delta = 0.5;
my $minForkSize = 50;
my $maxForkSize = int($buffer_size / (2 * $fork_number)) || 1;
my $active_forks = 0;
my (@pids, %by_pid, %children_reported_back);
my $sel = IO::Select->new;
sub _forked_process {
  my $buffer = shift;
  my $vfs = shift;
  my $parent = shift;
  my $output_as_hash = shift;

  # for testing
  kill $self->{_kill_self}, $$ if $self->{_kill_self};

  # simulate a memory leak
  # my $loop = 1;
  # my $mem_leak = sub { my ($a, $b); $a = \$b; $b = \$a; print STDERR "$$ ".($loop / 1e6)."\n" if ++$loop % 1e6 == 0};
  # &$mem_leak() while(1);

  # redirect and capture STDERR
  $self->config->{warning_fh} = *STDERR;
  close STDERR;
  my $stderr;
  open STDERR, '>', \$stderr;
  
  # reset the input buffer and add a chunk of data to its pre-buffer
  # this way it gets read in on the following next() call
  # which will be made by _buffer_to_output()
  $buffer->{buffer_size} = scalar @$vfs;
  $buffer->reset_buffer();
  $buffer->reset_pre_buffer();
  push @{$buffer->pre_buffer}, @$vfs;

  # reset stats
  $self->stats->{stats}->{counters} = {};

  # reset FASTA DB
  delete($self->config->{_fasta_db});
  $self->fasta_db;

  # reset custom sources' parsers
  # otherwise we get cross-pollution between forks reading from the same filehandles (I think)
  delete $_->{parser} for @{$self->get_all_AnnotationSources};

  # we want to capture any deaths and accurately report any errors
  # so we use eval to run the core chunk of the code (_buffer_to_output)
  my $output;
  eval {
    # for testing
    $self->warning_msg('TEST WARNING') if $self->{_test_warning};
    throw('TEST DIE') if $self->{_test_die};

    # the real thing
    $output = $self->_buffer_to_output($buffer, $output_as_hash);
  };
  my $die = $@;

  # some plugins may cache stuff, check for this and try and
  # reconstitute it into parent's plugin cache
  my $plugin_data;

  foreach my $plugin(@{$self->get_all_Plugins}) {
    next unless $plugin->{has_cache};

    # delete unnecessary stuff and stuff that can't be serialised
    delete $plugin->{$_} for qw(config feature_types variant_feature_types version feature_types_wanted variant_feature_types_wanted params);

    $plugin_data->{ref($plugin)} = $plugin;
  }
  # send everything we've captured to the parent process
  # PID allows parent process to re-sort output to correct order
  print $parent freeze({
    pid => $$,
    output => $output,
    plugin_data => $plugin_data,
    stderr => $stderr,
    die => $die,
    stats => $self->stats->{stats}->{counters},
    _VEP_CACHE => $main::_VEP_CACHE,
  });

  exit(0);
}
