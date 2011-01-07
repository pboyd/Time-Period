use strict;
use warnings;

use Test::More tests => 2;

use constant TESTED_CLASS => 'Time::Period';

BEGIN { use_ok(TESTED_CLASS) };

can_ok(TESTED_CLASS, 'inPeriod');

my $base_date = 1293858000; # 01/01/2011 00:00:00 (Saturday)

is(inPeriod($base_date, 'wd {sa}'), 1, 'should match by exact weekday');
