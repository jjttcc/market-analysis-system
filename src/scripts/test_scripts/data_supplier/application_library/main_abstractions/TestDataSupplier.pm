# $Revision$ $Date$

package TestDataSupplier;
$VERSION = 1.00;
use strict;
use warnings;
use Carp;
use File::Spec::Functions;
use FileHandle;
use IO::Socket;
use base qw(CommunicationProtocol);


=head1 NAME

TestDataSupplier

=head1 SYNOPSIS

TBD

=head1 DESCRIPTION

Fake socket-based data-supplier for the MAS server, for testing

=cut


# --------------- Public features ---------------

# Basic operations

my $debug_file = FileHandle->new(">/tmp/debug." . $$);

	# Wait for and service client requests.
	sub execute {
		my ($self) = @_;
		my $socket = $self->field_value_for(qw(socket));
print "My socket is: $socket\n";
		while (1) {
			my $active_socket = $socket->accept;
			if (not $active_socket) {
				$self->report_error;
			} else {
				$self->process($active_socket);
			}
		}
	}

# --------------- Non-public features ---------------

# Initialization

	sub initialize {
		my ($self, %args) = @_;
		my $new_socket = IO::Socket::INET->new(
			LocalAddr => 'localhost', LocalPort => 39415, Proto => 'tcp',
			Listen => 5);
		die "$!" unless $new_socket;
		$self->set_field(qw(socket), $new_socket);
print "Socket was created: ", $self->field_value_for(qw(socket)), "\n";
		$self->SUPER::initialize(@_);
	}

# Implementation - meta-routines

	# All non-public attributes
	sub non_public_attributes {
		$_[0]->enforce_access_policy(caller) if DEBUG;
		(
		'socket'
		);
	}

# Implementation

	# Report the last error that occurred.
	sub report_error {
		my ($self) = @_;
		print STDERR "Error occurred: $!";
	}

	# Process the client request associated with the specified socket.
	sub process {
		my ($self, $socket) = @_;
		my $client_request = <$socket>;
		chomp $client_request;
print $debug_file "received msg: '$client_request'\n";
		my @fields = split $self->message_component_separator, $client_request;
print $debug_file "fields: '", join ", ", @fields, "'\n";
		die "Wrong # of fields: @fields" if @fields <= 1;
		my $req_id = $fields[0];
# Assume data request, for now!!!
		my $date_time_range = $fields[1];
		my $data_flags = $fields[2];
		my $symbol = $fields[3];
print $debug_file "req id: '$req_id', dtrange: '$date_time_range'\n";
print $debug_file "flags: '$data_flags', symbol: '$symbol'\n";
print "starting process with symbol '$symbol'\n";
$debug_file->flush;
		my $test_data = $self->data_for($symbol, 0);
		chomp $client_request;
		print "'process' received socket request: $client_request\n";
print "A\n";
print "sending: '" . $test_data, "'\n";
		$socket->send($test_data . "\n");
print "B\n";
		$socket->flush;
		$socket->close;
print "C\n";
	}

	# Data for the specification: symbol, whether-it-is-intraday
	sub data_for {
		my ($self, $symbol, $intraday) = @_;
		my $infile = FileHandle->new;
		my $result;
		my @lines;
		my $filename = $symbol . ".txt";
print "reading data from " . $filename, "\n";
		if (not $infile->open("< " . $filename)) {
			$result = "Supplier: Open of input file failed.";
		} else {
			@lines = <$infile>;
print "Sending " . @lines . " lines\n";
		}
		$result = join("", @lines);
#print "result is $result\n";
		$result;
	}

#"20050214,8.4,8.8,8.4,8.65,12133412\n" .
#"20050215,8.4,8.7,8.2,8.5,1123428\n" .
#"20050216,8.5,8.875,8.15,8.25,1121234\n" .
#"20050217,8.6,9.9,8.6,9.25,1131233\n" .
#"20050218,8.9,9.8,8.9,9.45,1012334\n";

1;
