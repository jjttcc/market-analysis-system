# $Revision$ $Date$

package TestDataSupplier;
$VERSION = 1.00;
use strict;
use warnings;
use Carp;
use File::Spec::Functions;
use FileHandle;
use IO::Socket;
use FileBasedDataDispenser;
use base qw(CommunicationProtocol);


=head1 NAME

TestDataSupplier

=head1 SYNOPSIS

TBD

=head1 DESCRIPTION

Fake socket-based data-supplier for the MAS server, for testing

=cut

my %req_handlers = (
	CommunicationProtocol::sym_list_req_id, \&process_symlist_request,
	CommunicationProtocol::data_req_id, \&process_data_request,
	CommunicationProtocol::daily_avail_req_id, \&process_daily_avail_request,
	CommunicationProtocol::intra_avail_req_id, \&process_intraday_avail_request
);

# !!!!remove:
#print CommunicationProtocol::sym_list_req_id, "\n";
#print CommunicationProtocol::data_req_id, "\n";
#print CommunicationProtocol::daily_avail_req_id, "\n";
#print CommunicationProtocol::intra_avail_req_id, "\n";
#print join "\n", keys %req_handlers, "\n";
#print join "\n", values %req_handlers, "\n";
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
		$self->set_field(qw(data_dispenser), FileBasedDataDispenser->new);
print "Socket was created: ", $self->field_value_for(qw(socket)), "\n";
		$self->SUPER::initialize(@_);
	}

# Implementation - meta-routines

	# All non-public attributes
	sub non_public_attributes {
		$_[0]->enforce_access_policy(caller) if DEBUG;
		(
		'socket',
		'data_dispenser'
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
# !!!		die "Wrong # of fields: @fields" if @fields <= 1;
		my $req_id = $fields[0];
print $debug_file "req id: '$req_id'\n";
$debug_file->flush;
print $req_handlers{$req_id}, "\n";
		$req_handlers{$req_id}->($self, $socket, \@fields);
	}

	sub process_symlist_request {
		my ($self, $socket, $fields) = @_;
		my $dispenser = $self->field_value_for(qw(data_dispenser));
		$socket->send(join("\n", $dispenser->symbols) . "\n");
		$socket->flush;
		$socket->shutdown(2);
	}

	sub process_daily_avail_request {
		my ($self, $socket, $fields) = @_;
# Hard code 'true' for now.
print "pDar sending ", $self->true, "\n";
		$socket->send($self->true . "\n");
		$socket->flush;
		$socket->shutdown(2);
	}

	sub process_intraday_avail_request {
		my ($self, $socket, $fields) = @_;
# Hard code 'false' for now.
print "piar sending ", $self->false, "\n";
		$socket->send($self->false . "\n");
		$socket->flush;
		$socket->shutdown(2);
	}

	sub process_data_request {
		my ($self, $socket, $fields) = @_;
		my $date_time_range = $$fields[1];
		my $data_flags = $$fields[2];
		my $symbol = $$fields[3];
print $debug_file "dtrange: '$date_time_range'\n";
print $debug_file "flags: '$data_flags', symbol: '$symbol'\n";
print "starting process with symbol '$symbol'\n";
$debug_file->flush;
		my $dispenser = $self->field_value_for(qw(data_dispenser));
		my $data;
		if ($data_flags =~ $self->intraday_flag) {
			$data = $dispenser->intraday_data_for($symbol, 0);
		} else {
			$data = $dispenser->daily_data_for($symbol, 0);
		}
#print "sending: '" . $data, "'\n";
		$socket->send($data . "\n");
		$socket->flush;
		$socket->shutdown(2);
	}

# !!!!:
	sub old_remove_process_data_request {
		my ($self, $socket, $fields) = @_;
		my $date_time_range = $$fields[1];
		my $data_flags = $$fields[2];
		my $symbol = $$fields[3];
print $debug_file "dtrange: '$date_time_range'\n";
print $debug_file "flags: '$data_flags', symbol: '$symbol'\n";
print "starting process with symbol '$symbol'\n";
$debug_file->flush;
		my $data = $self->data_for($symbol, 0);
#print "sending: '" . $data, "'\n";
		$socket->send($data . "\n");
		$socket->flush;
		$socket->shutdown(2);
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

1;
