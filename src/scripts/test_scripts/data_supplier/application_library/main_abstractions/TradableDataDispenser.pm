# $Revision$ $Date$

package TradableDataDispenser;
$VERSION = 1.00;
use strict;
use warnings;
use Carp;
use File::Spec::Functions;
use FileHandle;
use base qw(Any);


=head1 NAME

TradableDataDispenser

=head1 SYNOPSIS

TBD

=head1 DESCRIPTION

Dispensers of tradable data sets

=cut

# --------------- Public features ---------------

# Access

	sub symbols {
		my ($self) = @_;
		$self->handle_abstract_call(@_, 'symbols');
	}

	# "Daily" data for the specified symbol
	sub daily_data_for {
		my ($self) = @_;
		$self->handle_abstract_call(@_, 'daily_data_for');
	}

	# "Intraday" data for the specified symbol
	sub intraday_data_for {
		my ($self) = @_;
		$self->handle_abstract_call(@_, 'intraday_data_for');
	}

# Status report

	# Is "daily" (sometimes known as end-of-day) data available?
	sub daily_data_available {
		my ($self) = @_;
		$self->handle_abstract_call(@_, 'daily_data_available');
	}

	# Is "intraday" data available?
	sub intraday_data_available {
		my ($self) = @_;
		$self->handle_abstract_call(@_, 'intraday_data_available');
	}

# --------------- Non-public features ---------------

1;
