# $Revision$ $Date$

package NetworkProtocol;
$VERSION = 1.00;
use strict;
use warnings;
use Carp;
use File::Spec::Functions;
use FileHandle;
use IO::Socket;
use base qw(Any);


=head1 NAME

NetworkProtocol

=head1 SYNOPSIS

TBD

=head1 DESCRIPTION

Protocol for communication with the client

=cut


# --------------- Public features ---------------

# Access

	# End of message specifier
	use constant eom => '';

	# Field separator for messages sent and received by the server
	use constant message_field_separator => "%T";

	# Record separator for messages sent and received by the server
	use constant message_record_separator => "%N";

1;
