use strict;
use warnings;

use Test::More tests => 18;
use Time::Period;

my $base_date = 1293858000; # 01/01/2011 00:00:00 (Saturday)
my $day = 24 * 60 * 60;

is(inPeriod($base_date, 'yd {1}'), 1, 'should match a single day');
is(inPeriod($base_date, 'yday {1}'), 1, 'should match a single day, by the long form');
is(inPeriod($base_date - $day, 'yd {1}'), 0, 'should be able to not match a single day');

is(inPeriod($base_date + $day, 'yd {1-3}'), 1, 'should be able to match a range of days');
is(inPeriod($base_date - $day, 'yd {1-3}'), 0, 'should be able to not match a range of days');

is(inPeriod($base_date, 'yd {365-5}'), 1, 'should be able to match a range of days when the first year day is greater than the second');
is(inPeriod($base_date - $day, 'yd {365-5}'), 1, 'should be able to match a range of days when the first year day is greater than the second');
is(inPeriod($base_date - $day * 20, 'yd {365-5}'), 0, 'should be able to not match a range of days when the first year day is greater than the second');

is(inPeriod($base_date + $day * 5, 'yd {1-2}'), 0, 'should be able to not match a range of days when the first year day is less than the second');

is(inPeriod(0, 'yd {one}'), -1, 'should return -1 for non-numeric day numbers (single)');
is(inPeriod(0, 'yd {one - 3}'), -1, 'should return -1 for non-numeric day numbers (left)');
is(inPeriod(0, 'yd {3-one}'), -1, 'should return -1 for non-numeric day numbers (right)');

is(inPeriod(0, 'yd {0}'), -1, 'should return -1 for day numbers less than 1 (single)');
is(inPeriod(0, 'yd {0-3}'), -1, 'should return -1 for day numbers less than 1 (left)');
is(inPeriod(0, 'yd {3-0}'), -1, 'should return -1 for day numbers less than 1 (right)');

is(inPeriod(0, 'yd {366}'), -1, 'should return -1 for day numbers greater than 365 (single)');
is(inPeriod(0, 'yd {366-1}'), -1, 'should return -1 for day numbers greater than 365 (left)');
is(inPeriod(0, 'yd {1-366}'), -1, 'should return -1 for day numbers greater than 365 (right)');
