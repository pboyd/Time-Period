=head1 NAME

Time::Period - A Perl module to deal with time periods.

=head1 SYNOPSIS

C<use Time::Period;>

C<$result = inPeriod($time, $period);>

=head1 DESCRIPTION

The B<inPeriod> function determines if a given time falls within a given
period.  B<inPeriod> returns B<1> if the time does fall within the given
period, B<0> if not, and B<-1> if B<inPeriod> detects a malformed time or
period.

The time is specified as per the C<time()> function, which is assumed to
be the number of non-leap seconds since January 1, 1970.

The period is specified as a string which adheres to the format

	sub-period[, sub-period...]

or the string "none" or whitespace.  The string "none" is not case
sensitive.

If the period is blank, then any time period is assumed because the time
period has not been restricted.  In that case, B<inPeriod> returns 1.  If
the period is "none", then no time period applies and B<inPeriod> returns
0.

A sub-period is of the form

	scale {range [range ...]} [scale {range [range ...]}]

Scale must be one of nine different scales (or their equivalent codes):

	Scale  | Scale | Valid Range Values
	       | Code  |
	*******|*******|************************************************
	year   |  yr   | n     where n is an integer 0<=n<=99 or n>=1970
	month  |  mo   | 1-12  or  jan, feb, mar, apr, may, jun, jul,
	       |       |           aug, sep, oct, nov, dec
	week   |  wk   | 1-6
	yday   |  yd   | 1-366
	mday   |  md   | 1-31
	wday   |  wd   | 1-7   or  su, mo, tu, we, th, fr, sa
	hour   |  hr   | 0-23  or  12am 1am-11am 12noon 12pm 1pm-11pm
	minute |  min  | 0-59
	second |  sec  | 0-59

The same scale type may be specified multiple times.  Additional scales
simply extend the range defined by previous scales of the same type.

The range for a given scale must be a valid value in the form of

	v

or

	v-v

For the range specification v-v, if the second value is larger than
the first value, the range wraps around unless the scale specification
is year.

Year does not wrap because the year is never really reset, it just
increments.  Ignoring that fact has lead to the dreaded year 2000
nightmare.  When the year rolls over from 99 to 00, it has really rolled
over a century, not gone back a century.  B<inPeriod> supports the
dangerous two digit year notation because it is so rampant.  However,
B<inPeriod> converts the two digit notation to four digits by prepending
the first two digits from the current year.  In the case of 99-1972, the
99 is translated to whatever current century it is (probably 20th), and
then range 99-1972 is treated as 1972-1999.  If it were the 21st century,
then the range would be 1972-2099.

Anyway, if v-v is 9-2 and the scale is month, September, October,
November, December, January, and February are the months that the range
specifies.  If v-v is 2-9, then the valid months are February, March,
April, May, Jun, July, August, and September.  9-2 is the same as Sep-Feb.

v isn't a point in time.  In the context of the hour scale, 9 specifies
the time period from 9:00:00 am to 9:59:59 am.  This is what most people
would call 9-10.  In other words, v is discrete in its time scale.
9 changes to 10 when 9:59:59 changes to 10:00:00, but it is 9 from
9:00:00 to 9:59:59.  Just before 9:00:00, v was 8.

Note that whitespace can be anywhere and case is not important.  Note
also that scales must be specified either in long form (year, month,
week, etc.) or in code form (yr, mo, wk, etc.).  Scale forms may be
mixed in a period statement.

Furthermore, when using letters to specify ranges, only the first two
for week days or the first three for months are significant.  January
is a valid specification for jan, and Sunday is a valid specification
for su.  Sun is also valid for su.

=head2 PERIOD EXAMPLES

To specify a time period from Monday through Friday, 9am to 5pm, use a
period such as

	wd {Mon-Fri} hr {9am-4pm}

When specifing a range by using -, it is best to think of - as meaning
through.  It is 9am through 4pm, which is just before 5pm.

To specify a time period from Monday through Friday, 9am to 5pm on
Monday, Wednesday, and Friday, and 9am to 3pm on Tuesday and Thursday,
use a period such as

	wd {Mon Wed Fri} hr {9am-4pm}, wd{Tue Thu} hr {9am-2pm}

To specify a time period that extends Mon-Fri 9am-5pm, but alternates
weeks in a month, use a period such as

	wk {1 3 5} wd {Mon Wed Fri} hr {9am-4pm}

Or how about a period that specifies winter?

	mo {Nov-Feb}

This is equivalent to the previous example:

	mo {Jan-Feb Nov-Dec}

As is

	mo {jan feb nov dec}

And this is too:

	mo {Jan Feb}, mo {Nov Dec}

Wait!  So is this:

	mo {Jan Feb} mo {Nov Dec}

To specify a period that describes every other half-hour, use something
like

	minute { 0-29 }

To specify the morning, use

	hour { 12am-11am }

Remember, 11am is not 11:00:00am, but rather 11:00:00am - 11:59:59am.

Hmmmm, 5 second blocks could be a fun period...

	sec {0-4 10-14 20-24 30-34 40-44 50-54}

To specify every first half-hour on alternating week days, and the second
half-hour the rest of the week, use the period

	wd {1 3 5 7} min {0-29}, wd {2 4 6} min {30-59}

=head1 VERSION

1.20

=head1 HISTORY

	Version 1.20
	------------
		- Added the ability to specify no time period.

	Version 1.13
	------------
		- Cleaned up the error checking code.

	Version 1.12
	------------
		- Updated email and web space information.

	Version 1.11
	------------
		- Minor bug fix in 1.10.

	Version 1.10
	------------
		- Released.

=head1 AUTHOR

Patrick Ryan <pgryan@geocities.com>

=head1 COPYRIGHT

Copyright (c) 1997 Patrick Ryan.  All rights reserved.  This Perl module
uses the conditions given by Perl.  This module may only be distributed
and or modified under the conditions given by Perl.

=head1 DATE

August 26, 1997

=head1 SOURCE

This distribution can be found at

	http://www.geocities.com/SiliconValley/Lakes/8456/

or

	http://www.perl.com/CPAN/modules/by-module/Time/

=cut

package Time::Period;

require 5.001;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(inPeriod);

$VERSION = "1.20";

sub inPeriod {
  my($time, $period) = @_[0,1];
  my $return = `python2 ../TimePeriod/TimePeriod.py $time '$period'`;

  chomp $return;
  return $return if $return eq 1 || $return eq 0;

  warn $return;
  return -1;
}

1;
