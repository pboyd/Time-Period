use strict;
use warnings;

use Test::More tests => 15;
use Time::Period;

my $base_date = 1293858000; # 01/01/2011 00:00:00 (Saturday)
my $year = 365 * 24 * 60 * 60;

is(inPeriod($base_date, 'yr {2011}'), 1, 'should match a single year');
is(inPeriod($base_date, 'yr {2010}'), 0, 'should be able to not match a single year');

is(inPeriod($base_date, 'yr {2010-2015}'), 1, 'should match a range of years');
is(inPeriod($base_date, 'yr {2015-2010}'), 1, 'should match a range of years when the first year is greater than the latter');
is(inPeriod($base_date, 'yr {2000-2009}'), 0, 'should be able to not match a range (too low)');
is(inPeriod($base_date, 'yr {2012-2013}'), 0, 'should be able to not match a range (too high)');

is(inPeriod($base_date - 20 * $year, 'yr {90-95}'), 1, 'should do the right thing for a range when the year is less than 100');
is(inPeriod($base_date - 20 * $year, 'yr {91}'), 1, 'should do the right thing for a single year when it\'s less than 100');

is(inPeriod($base_date, 'yr {}'), 0, 'should never match an empty year');

is(inPeriod(0, 'yr {1960}'), -1, 'should return -1 for years before 1970 (single)');
is(inPeriod(0, 'yr {1960-2000}'), -1, 'should return -1 for years before 1970 (left)');
is(inPeriod(0, 'yr {2000-1960}'), -1, 'should return -1 for years before 1970 (right)');

is(inPeriod(0, 'yr {_}'), -1, 'should return -1 for non-alphnumeric years (single)');
is(inPeriod(0, 'yr {_ - 2000}'), -1, 'should return -1 for non-alphnumeric years (left)');
is(inPeriod(0, 'yr {2000 - _}'), -1, 'should return -1 for non-alphnumeric years (right)');
