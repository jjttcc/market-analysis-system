# $Revision$ $Date$

package TestDataSupplier;
$VERSION = 1.00;
use strict;
use warnings;
use Carp;
use File::Spec::Functions;
use FileHandle;
use IO::Socket;
use base qw(Any);


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
print "I, $self, am executing\n";
print "My socket is: $socket\n";
if ($socket->connected) {
print "Socket is connected.\n";
} else {
print "Socket is NOT connected.\n";
}
		$socket->listen;
		my $active_socket = $socket->accept;
	}

# --------------- Non-public features ---------------

# Initialization

	sub initialize {
		my ($self, %args) = @_;
		my $new_socket = IO::Socket::INET->new(
			LocalAddr => 'localhost', LocalPort => 39412, Proto => 'tcp',
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

1;
