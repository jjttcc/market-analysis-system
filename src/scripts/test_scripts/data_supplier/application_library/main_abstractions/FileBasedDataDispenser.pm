# $Revision$ $Date$

package FileBasedDataDispenser;
$VERSION = 1.00;
use strict;
use warnings;
use Carp;
use File::Spec::Functions;
use FileHandle;
use base qw(TradableDataDispenser CommunicationProtocol);


=head1 NAME

FileBasedDataDispenser

=head1 SYNOPSIS

TBD

=head1 DESCRIPTION

Dispensers of tradable data sets

=cut

# --------------- Public features ---------------

# Access

	sub symbols {
		my ($self) = @_;
		my $files = $self->field_value_for(qw(data_files));
		my @result = map {
			/(.*)\.txt/; $1
		} @$files;
print "symbols returning @result\n";
		return @result;
	}

	# "Daily" data for the specified symbol
	sub daily_data_for {
		# Expected file name format: <symbol>.txt
		my ($self, $symbol, $date_time_range) = @_;
		my @start_end_times = $self->time_range_components($date_time_range);
# !!!!Use @start_end_times!!!
# parse $date_time_range and use it to filter input!!!!!!
print "daily-data-for - date_time_range: $date_time_range\n";
		my $infile = FileHandle->new;
		my $result;
		my @lines;
		my $filename = $self->daily_filename($symbol);
print "reading DAILY data from " . $filename, "\n";
		if (not $infile->open("< " . $filename)) {
			$result = "Supplier: Open of input file failed.";
		} else {
			@lines = <$infile>;
print "Sending " . @lines . " lines\n";
		}
		if (@start_end_times) {
			@lines = $self->data_in_range(\@lines, \@start_end_times,
				$self->false);
		}
		$result = join("", @lines);
print "result is $result\n";
		$result;
	}

	# "Intraday" data for the specified symbol
	sub intraday_data_for {
		# Expected file name format: <symbol>.intraday.txt
		my ($self, $symbol, $date_time_range) = @_;
		my @start_end_times = $self->time_range_components($date_time_range);
# !!!!Use @start_end_times!!!
print "intraday-data-for - date_time_range: $date_time_range\n";
# parse $date_time_range and use it to filter input!!!!!!
		my $infile = FileHandle->new;
		my $result;
		my @lines;
		my $filename = $self->intraday_filename($symbol);
print "reading INTRADAY data from " . $filename, "\n";
		if (not $infile->open("< " . $filename)) {
			$result = "Supplier: Open of input file failed.";
		} else {
			@lines = <$infile>;
print "Sending " . @lines . " lines\n";
		}
		if (@start_end_times) {
			@lines = $self->data_in_range(\@lines, \@start_end_times,
				$self->true);
		}
		$result = join("", @lines);
print "result is $result\n";
		$result;
	}

# Status report

	# Is "daily" (sometimes known as end-of-day) data available?
	sub daily_data_available {
		my ($self) = @_;
		my @symbs = $self->symbols;
		my $result = (@symbs > 0 and -e $self->daily_filename($symbs[0]));
print "daily avail: $result\n";
		$result;
	}

	# Is "intraday" data available?
	sub intraday_data_available {
		my ($self) = @_;
		my @symbs = $self->symbols;
		my $result = (@symbs > 0 and -e $self->intraday_filename($symbs[0]));
print "int fname: ", $self->intraday_filename($symbs[0]), "\n";
if ($result) {
print "int file exists\n";
} else {
print "int file DOES NOT exist\n";
}
		$result;
	}

# --------------- Non-public features ---------------

# Initialization

	sub initialize {
		my ($self, %args) = @_;
		my @files = grep {
			! /intraday/
		} <*.txt>;
system("pwd");
print "init - files: ", (join ", ", @files), "\n";
		$self->set_field(qw(data_files), \@files);
		$self->SUPER::initialize(@_);
	}

# Implementation - meta-routines

	# All non-public attributes
	sub non_public_attributes {
		$_[0]->enforce_access_policy(caller) if DEBUG;
		(
		# All available data files
		'data_files',
		);
	}

# Implementation - utilities

	# Name of the daily data file for the specified symbol
	sub daily_filename {
		my ($self, $sym) = @_;
		return $sym . ".txt";
	}

	# Name of the intraday data file for the specified symbol
	sub intraday_filename {
		my ($self, $sym) = @_;
		return $sym . ".intraday.txt";
	}

	# Date/time-range components, an array whose components occur in the
	# following sequence: (start-date, start-time, end-date, end-time)
	sub time_range_components {
		my ($self, $dtspec) = @_;
		my @result = ();
print "time_range_components was given: $dtspec\n";
		if ($dtspec) {
			my @st_end = split($self->date_time_range_separator, $dtspec);
			my @start = split($self->date_time_separator, $st_end[0]);
			my $date = $self->date_from_spec($start[0]);
			my $time = $self->time_from_spec($start[1]);
			# Insert the start date, time.
			push @result, ($date, $time);
			if (@st_end > 1) {
				my @end = split($$self->date_time_separator, $st_end[1]);
				my $date = $self->date_from_spec($end[0]);
				my $time = $self->time_from_spec($end[1]);
				# Insert the end date, time.
				push @result, ($date, $time);
			}
		}
print "time_range_components returning: ", join(", ", @result), "\n";
		@result;
	}

	# Date from a date-spec - empty string if spec is empty or invalid
	sub date_from_spec {
		my ($self, $result) = @_;
		$result =~ s@/@@g;	# Remove '/'s.
		if (not $result) {
			$result = "";
		}
		$result;
	}

	# Time from a date-spec - empty string if spec is empty or invalid
	sub time_from_spec {
		my ($self, $result) = @_;
		$result =~ s/([^:]*:[^:]*):.*/$1/;	# Remove the 'seconds' component.
		if (not $result) {
			$result = "";
		}
		$result;
	}

	sub data_in_range {
		my ($self, $lines, $start_end_times, $intraday) = @_;
		my $first_index = -1;	# Index of 1st matching record
print "dt in rng - intraday: $intraday\n";
print "sz of stetims: ", @$start_end_times + 0, "\n";
print "contents of stetims: ", join(", ", @$start_end_times), "\n";
		# (Ignore end-date/time for now.)
		my @result = ();
		my $start_time = '';
		my $start_date = $$start_end_times[0];
		my $i = -1;
		if ($intraday) {
			$start_time = $$start_end_times[1];
		}
# Force for testing:
($start_date, $start_time) = (20010306, '11:05');
# !!!!!!!!!!!! Continue - Extract only the elements of @$lines whose
# date/times match st.date, st.time (probably go backwards) ...
# !!!!!!!!!!!!!!!!!!!!!!!!NOTE: Don't forget to investigate the
# "Wrong # of fields" errors that are printed at the beginning of output.
print "data in range - st date/time: $start_date/$start_time\n";
		my $last_line = $$lines[$#$lines];
print "last line: $last_line\n";
		my ($last_dt, $last_tm) =
			split $self->date_time_separator, $last_line, 3;
print "last line - 1st 2 fields: $last_dt, $last_tm\n";
		if ($last_dt >= $start_date) {
			my ($start_hour, $start_minute) =
				split $self->time_field_separator, $start_time;
			$i = $#$lines - 1;	# Index of next-to-last item in @$lines
			if ($last_dt == $start_date) {
				assert($$lines[$i + 1] =~ /^$start_date/);
				# Continue to decrement $i until $$lines[$i] no longer matches
				# $start_date.
				while ($i >= 0 && $$lines[$i] =~ /^$start_date/) {
					--$i;
				}
			} else {
				assert($$lines[$i + 1] !~ /^$start_date/);
				my ($cur_date) =
					split $self->date_time_separator, $$lines[$i], 2;
print "i ($i) to be decremented - lines[i]: ", $$lines[$i], "\n";
				assert($cur_date > $start_date);
				while ($i >= 0 && $cur_date >= $start_date) {
print "cur date, start date: $cur_date, $start_date\n";
print "i, lines[i]: $i, ", $$lines[$i], "\n";
					--$i;
					($cur_date) =
						split $self->date_time_separator, $$lines[$i], 2;
				}
				assert($i == -1 || $cur_date < $start_date);
print "i was decremented to $i lines[i]: ", $$lines[$i], "\n";
			}
print "i, lines[i], sd: $i, ", $$lines[$i], ", ", $start_date, "\n";
			assert($i == -1 || $$lines[$i] !~ /^$start_date/);
			++$i;
print "i, lines[i], sd: $i, ", $$lines[$i], ", ", $start_date, "\n";
			assert($i == 0 || $$lines[$i] =~ /^$start_date/);
print "[A] We are at line $i: ", $$lines[$i], "\n";
			if ($i < @$lines && $start_hour) {
				while ($i < @$lines && $first_index < 0) {
					my @cur_fields =
						split $self->data_field_separator, $$lines[$i];
					my ($cur_hour, $cur_minute) =
						split $self->time_field_separator, $cur_fields[1];
print "[B] We are at line $i: ", $$lines[$i], "\n";
print "cur hour, minute: $cur_hour, $cur_minute\n";
					if ($cur_hour > $start_hour) {
						# A gap occurred such that the current hour (from
						# $$lines[$i]) is > the requested start hour;
						# therefore the current record is the first one
						# to match the requested date range.
						$first_index = $i;
					} elsif ($cur_hour == $start_hour) {
						if ($cur_minute > $start_minute) {
							$first_index = $i;
							last;	# Found the first matching record.
						}
						assert($cur_hour == $start_hour &&
							$cur_minute < $start_minute);
						++$i;
						while ($i < @$lines && $first_index < 0) {
							@cur_fields =
								split $self->data_field_separator, $$lines[$i];
							($cur_hour, $cur_minute) = split
								$self->time_field_separator, $cur_fields[1];
							if ($cur_hour > $start_hour ||
									$cur_minute > $start_minute) {
								$first_index = $i;
							}
							++$i;
						}
					}
					++$i;
				}
			}
		}
if ($first_index >= 0) {
	print "found our record at ($first_index): ", $$lines[$first_index], "\n";
	print "i is $i\n";
exit 77;
} else {
	print "Didn't find our record\n";
	print "i is $i\n";
exit 42;
}
print "dir result: ", join(" ", @result), "\n";
exit 34;
	}

1;
