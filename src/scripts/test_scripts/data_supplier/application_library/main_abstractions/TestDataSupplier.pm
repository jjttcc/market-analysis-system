# $Revision$ $Date$

package TestDataSupplier;
$VERSION = 1.00;
use strict;
use warnings;
use Carp;
use Task;
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
	}

# --------------- Non-public features ---------------

# Initialization

	sub initialize {
		my ($self, %args) = @_;
		$self->set_field(qw(socket), IO::Socket::INET->new(
			LocalAddr => 'localhost', LocalPort => 39412, Proto => 'tcp',
			Listen    => 5));
		die "$!" unless $sock;
print "Socket was created: " . $self->socket;
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
