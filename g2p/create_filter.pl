use strict;
use warnings;

my $af = 'AFR_AF|AMR_AF|EAS_AF|EUR_AF|SAS_AF|AA_AF|EA_AF|gnomAD_AF|gnomAD_AFR_AF|gnomAD_AMR_AF|gnomAD_ASJ_AF|gnomAD_EAS_AF|gnomAD_FIN_AF|gnomAD_NFE_AF|gnomAD_OTH_AF|gnomAD_SAS_AF';


my @afs = split('\|', $af);
print join(" and ", map {"($_ < 0.001 or not $_)"} @afs), "\n";
