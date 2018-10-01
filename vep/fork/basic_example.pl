use strict;
use warnings;
 
print "Process ID: $$\n";
 
my $n = 3;
my $forks = 0;
for (1 .. $n) {
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
    sleep 2;
    print "Child ($$) exiting\n";
    exit;
  }
}
 
for (1 .. $forks) {
   my $pid = wait();
   print "Parent saw $pid exiting\n";
}
print "Parent ($$) ending\n";
