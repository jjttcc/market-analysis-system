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

	# OK status_id
	use constant ok_id => '1';

	# Error status_id
	use constant error_id => '2';

1;
