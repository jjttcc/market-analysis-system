#!/usr/bin/env perl -w

# Retrieve free stock data from an internet site - currently hard-coded to
# use qm (quotemonster) to retrieve data from yahoo.com.  Search for
# "Plug in" to find the code for configuring for a different retrieval script.

use Time::Local;
use diagnostics;
use strict;
use FileHandle;

package mas_external_retrieve;
use vars qw/ $Sun $Mon $Tue $Wed $Thu $Fri $Sat $current_date_time $data_time_span_in_years $intraday $symbol $backup_file $retrieve_command_implementation $mer_result $output_filter @market_close_time $working_directory $symbol_file $error_regex $input_file $output_file /;

$current_date_time = -1;
($Sun, $Mon, $Tue, $Wed, $Thu, $Fri, $Sat) = (0 .. 6);
# Plug in: Adjust this value to the number of years of data desired:
$data_time_span_in_years = 3;
$mer_result = 0;

if (@ARGV < 3) {
	usage();
	exit 1;
}

setup();
if ($intraday) {
	warn "Intraday data is not currently supported.\n";
	exit 1;
}
if (backup_file_exists()) {
	use File::Copy;
print "Using backup data for $symbol\n";
	copy $backup_file => $output_file or
			warn "can't copy $backup_file to $output_file:\n$!" and exit 1;
	my $datafile = new FileHandle $output_file, 'r';
	my @lastdate = "";
	@lastdate = lastdate($datafile);
print "last date:", join(', ', @lastdate), "\n";
	if (out_of_date(@lastdate)) {
print "Updating data ...\n";
		# Note: All data is retrieved - need to optimize to just append
		# the last day (or whatever is missing).
		my @nowdate = date_from_localtime(now());
		$mer_result = retrieve_data(@lastdate, @nowdate);
		if ($mer_result == 0) {
			append_data_to_output_file();
			save_data();
		}
	} else {
print "Data is up to date.\n";
	}
} else {
print "Retrieving fresh data for $symbol\n";
	my @nowdate = date_from_localtime(now());
	$mer_result = retrieve_data(adjusted_start_date(@nowdate), @nowdate);
	if ($mer_result == 0) {
		copy_data_to_output_file();
		save_data();
	}
}

# Application-specific utilities

# The external command to retrieve the data
# Expected arguments: startdate, enddate
# where startdate and enddate are in the form yyyymmdd.
sub retrieve_command {
	# Call the plugged-in retrieve_command implementation.
	return $retrieve_command_implementation->(@_);
}

# The last date in the specified (open) stock data file (1st argument),
# in the format: (year, month, day)
sub lastdate {
	my $dt = $_[0];
	my @lines = <$dt>;
	if (@lines == 0) {
		return (0, 0, 0);
	}
	my $last = $lines[@lines - 1];
	$last =~ s/,.*//;
	my $y = substr($last, 0, 4);
	my $m = substr($last, 4, 2);
	my $d = substr($last, 6, 2);
	return $y, $m, $d;
}

# Is the argument (year, month, day) out-of-date compared to the current
# date/time?
sub out_of_date {
	my $result = 0;
	my $y = $_[0]; my $m = $_[1] - 1; my $d = $_[2];
	my @now = now();
	my $day = day(@now);
	my $month = month(@now);
	my $year = year(@now);
	my $hour = hour(@now);
	my $minutes = minutes(@now);
	my $current_wd = week_day(@now);
	if ($current_wd == $Sun || $current_wd == $Sat) {
		if ($year == $y && $month == $m) {
			if (($current_wd == $Sun && $day - $d > 2) ||
					($current_wd == $Sat && $day - $d > 1)) {
				$result = 1;
			}
		} else {
			# Different months and/or years - don't bother to figure out
			# how many days ago the date is.
			$result = 1;
		}
	} elsif (! dates_equal($year, $month, $day, $y, $m, $d)) {
		my @yesterday = before(1);
		if (! dates_equal(year(@yesterday), month(@yesterday),
				day(@yesterday), $y, $m, $d)) {
			$result = 1;
		} elsif (after_close_time(@now)) {
			$result = 1;
		}
	}
	return $result;
}

# Does $backup_file exist and is it not too old?
sub backup_file_exists {
	my $result = 0;
	if (-r $backup_file) {
		$result = 1;
	}
	return $result;
}

# Copy $output_file into a backup file based on $symbol.
sub save_data {
	copy($output_file, $backup_file) or
		warn "can't copy $output_file to $backup_file:\n$!" and exit 1;
}

# Retrieve the data for the current symbol (stored in $symbol_file).
# Expected arguments:
#    (startyear, startmonth, startday, endyear, endmonth, endday)
sub retrieve_data {
	my $result = 0;
	my $startdate = squished_date($_[0], $_[1], $_[2]);
	my $enddate = squished_date($_[3], $_[4], $_[5]);
	my @cmd = retrieve_command($startdate, $enddate);
	$result = system(@cmd);
	return $result;
}

# Copy the data in $input_file to $output_file, filtering out
# "^SYMBOL," at the beginning of each line using $output_filter.
sub copy_data_to_output_file {
	my $ifile; my $ofile;
	my $i; my $l;
	$ifile = new FileHandle $input_file, 'r';
	$ofile = new FileHandle $output_file, 'w';
	my @lines = <$ifile>;
	my $filter = "\$l =~ " . $output_filter;
	if (@lines == 0 || input_error($lines[0])) {
		my $msg = "Error encountered retrieving data";
		if (@lines > 0) {
			$msg .= ": $lines[0].\n";
		} else {
			$msg .= ".\n";
		}
		warn $msg;
		exit 1;
	}
	foreach $i (0 .. @lines - 1) {
		$l = $lines[$i];
		eval $filter;
		print $ofile $l;
	}
	close($ifile);
	close($ofile);
}

# Append the data in $input_file to $output_file, skipping the 1st line
# andfiltering out "^SYMBOL," at the beginning of each line using
# $output_filter.
sub append_data_to_output_file {
	my $ifile; my $ofile; my $i; my $l;
	$ifile = new FileHandle $input_file, 'r';
	$ofile = new FileHandle $output_file, 'a';
	my @lines = <$ifile>;
	my $filter = "\$l =~ " . $output_filter;
	if (@lines == 0 || input_error($lines[0])) {
		my $msg = "Error encountered retrieving data";
		if (@lines > 0) {
			$msg .= ": $lines[0].\n";
		} else {
			$msg .= ".\n";
		}
		warn $msg;
		exit 1;
	}
	foreach $i (1 .. @lines - 1) {
		$l = $lines[$i];
		eval $filter;
		print $ofile $l;
	}
	close($ifile);
	close($ofile);
}

# Is the specified time after $market_close_time?
sub after_close_time {
	my $hour = hour(@_);
	my $minutes = minutes(@_);
	my $result = 0;
	if ($hour == $market_close_time[0]) {
		if ($minutes > $market_close_time[1]) {
			$result = 1;
		}
	} elsif ($hour > $market_close_time[0]) {
		$result = 1;
	}
	return $result;
}

# Set-up utilities

# Parse command-line arguments.
sub parse_args {
	$intraday = 0;
	my $i = 0;
	if ($ARGV[0] eq "-i") {
		$intraday = 1;
		$i = 1;
	}
	$working_directory = $ARGV[$i++];
	$output_file = $ARGV[$i++];
	$symbol = $ARGV[$i];
}

sub set_plug_in_values {
	# Plug in the file into which the data-retrieval results are placed here:
	$input_file = "quotes.prn";
	# Plug in the file into which the symbol for the data to be retrieved
	# is placed here:
	$symbol_file = "tickers.txt";
	# Plug in the regular expression that will be used to transform the
	# input data (in $input_file) into the format expected in $output_file.
	# If no translation needs to be done, set $output_filter to "".
	$output_filter = "s/^[^,]*,//";
	# Plug in an approximate market close time (local time) for your region.
	# (Too early and time will be wasted retrieving unavailable data; too
	# late and your data will be out of date when it needn't be.)
	@market_close_time = (16, 55);	# format: (hour, minute)
	# Plug in the subroutine to produce the system command needed
	# to execute the external data-retrieving program here:
	$retrieve_command_implementation = \&qm_based_retrieve_command;
	# Plug in the regular expression used to determine if an error has
	# occurred in the input data here:
	$error_regex = "/[eE]rror/";
}

sub setup {
	parse_args();
	$backup_file = $symbol . ".mas";
	set_plug_in_values();
	chdir($working_directory);
	my $symfile = new FileHandle $symbol_file, 'w';
	print $symfile $symbol . "\n";
	close($symfile);
}

sub usage {
	print "Usage: $0 [-i] working_directory data_output_file symbol\n",
		"Options:\n",
		"  -i      retrieve intraday data (default is daily)\n";
}

# Is there an error in the record ($_[0])?
sub input_error {
	if (@_ == 0) {
		# Empty args are regarded as an error.
		return 1;
	}
	my $expr = "\$_[0] =~ $error_regex";
	if (eval "$expr") {
		return 1;
	} else {
		return 0;
	}
}

# Date-related utilities

# Argument (year, month, day) adjusted to start at the beginning of the
# month, $data_time_span_in_years years ago
sub adjusted_start_date {
	my $y = $_[0]; my $m = $_[1]; my $d = $_[2];
	return ($y - $data_time_span_in_years, $m, 1);
}

# Date converted from (y, m, d) to yyyymmdd
sub squished_date {
	return sprintf "%04u%02u%02u", $_[0], $_[1], $_[2];
}

# Day of the week from date/time array
sub week_day {
	return $_[6];
}

# Month from date/time array
sub year {
	return $_[5] + 1900;
}

# Month from date/time array
sub month {
	return $_[4];
}

# Day from date/time array
sub day {
	return $_[3];
}

# Hour from date/time array
sub hour {
	return $_[2];
}

# Minutes from date/time array
sub minutes {
	return $_[1];
}

# (year, month, day) from local time format, with start-at-1 adjustment
# for month
sub date_from_localtime {
	return (year(@_), month(@_) + 1, day(@_));
}

# Does date1 equal date2 (y1, m1, d1, y2, m2, d2)?
sub dates_equal {
	return $_[0] == $_[3] && $_[1] == $_[4] && $_[2] == $_[5];
}

# The current date and time in the `localtime' format
sub now {
	if ($current_date_time == -1) {
		$current_date_time = time();
	}
	my @t = localtime $current_date_time;
	return @t;
}

# A date before now, $_[0] days ago, in localtime format
sub before {
	my $days_before = $_[0];
	if ($current_date_time == -1) {
		$current_date_time = time();
	}
	my $before_time = $current_date_time - ($days_before * 86400);
	my @t = localtime $before_time;
	return @t;
}

# retrieve_command implementation that uses quotemonster
sub qm_based_retrieve_command {
	my $startdt = substr($_[0], 2, 6);
	my $enddt = substr($_[1], 2, 6);
	my @result = ("qm", $startdt, $enddt);
	return @result;
}
