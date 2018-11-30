use strict;
use warnings;






my ($first_value, $second_value) = @{return_values()};

print "$first_value, $second_value\n";



sub return_values {
  return [3, 4];
}
