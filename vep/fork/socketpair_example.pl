use strict;
use warnings;
use Storable qw(freeze thaw);
use IO::Socket;
use IO::Select; 
print "Process ID: $$\n";

my $sel = IO::Select->new;
 
my $n = 3;
my $forks = 0;
for (1 .. $n) {
  my ($child, $parent);
  socketpair($child, $parent, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or throw("ERROR: Failed to open socketpair: $!");
  $child->autoflush(1);
  $parent->autoflush(1);
  $sel->add($child);
  my $pid = fork;
  if (not defined $pid) {
     warn 'Could not fork';
     next;
  }
  if ($pid) {
    $forks++;
    print "In the parent process PID ($$), Child pid: $pid Num of fork child processes: $forks\n";
  } else {
    print "In the child process PID ($$)\n"; 
    add_random_numbers($parent);
    sleep 2;
    print "Child ($$) exiting\n";
    exit;
  }
}

while(my @ready = $sel->can_read()) {
  print scalar @ready, "\n";
  my $no_read = 1;
  foreach my $fh (@ready) {
    print "fh $fh\n";
    $no_read++;
    my $line = join('', $fh->getlines());
    print $line, "\n";
    next unless $line;
    $no_read = 0;
    $sel->remove($fh);
    $fh->close;
    $forks--;
  }
  last if $forks < 3;
  print "No read $no_read\n";
}

#for (1 .. $forks) {
#   my $pid = wait();
#   print "Parent saw $pid exiting\n";
#}
#print "Parent ($$) ending\n";

sub add_random_numbers {
  my $parent = shift;
  print $parent, "\n";
  die;
  print $parent freeze({
    pid => $$,
    output => 'output',
    plugin_data => 'plugin_data',
    stderr => 'stderr',
    die => 'die',
    stats => 'counters',
    _VEP_CACHE => 'vepcache',
  });

  exit(0);

}

