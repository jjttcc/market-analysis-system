# $Revision$ $Date$

package TestDataSupplier;
$VERSION = 1.00;
use strict;
use warnings;
use Carp;
use File::Spec::Functions;
use FileHandle;
use IO::Socket;
use base qw(NetworkProtocol);


=head1 NAME

TestDataSupplier

=head1 SYNOPSIS

TBD

=head1 DESCRIPTION

Fake socket-based data-supplier for the MAS server, for testing

=cut


# --------------- Public features ---------------

# Basic operations

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
			LocalAddr => 'localhost', LocalPort => 39414, Proto => 'tcp',
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
print "starting 'process'\n";
		my $client_request = <$socket>;
		chomp $client_request;
		print "'process' received socket request: $client_request\n";
print "A\n";
		$socket->send("Here is my response.  " .
			"What are you going to do about it?\n" . $self->eom);
print "B\n";
		$socket->flush;
		$socket->close;
print "C\n";
	}

1;
