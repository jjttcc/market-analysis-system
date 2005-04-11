# $Revision$ $Date$

package FileBasedDataDispenser;
$VERSION = 1.00;
use strict;
use warnings;
use Carp;
use File::Spec::Functions;
use FileHandle;
use base qw(TradableDataDispenser);


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
		my ($self, $symbol) = @_;
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
		$result = join("", @lines);
print "result is $result\n";
		$result;
	}

	# "Intraday" data for the specified symbol
	sub intraday_data_for {
		# Expected file name format: <symbol>.intraday.txt
		my ($self, $symbol) = @_;
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

# Implementation

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

1;
