# $Revision$ $Date$

package CommunicationProtocol;
$VERSION = 1.00;
use strict;
use warnings;
use Carp;
use File::Spec::Functions;
use FileHandle;
use IO::Socket;
use base qw(Any);


=head1 NAME

CommunicationProtocol

=head1 SYNOPSIS

TBD

=head1 DESCRIPTION

Protocol for communication with the client

=cut


# --------------- Public features ---------------

# Server response IDs

	# OK status_id
	use constant ok_id => '1';

	# Error status_id
	use constant error_id => '2';

# Server response values

	use constant true => 'T';

	use constant false => 'F';

# Component separators

	# Character used to separate top-level message components
	use constant message_component_separator => "\t";

	# Character used to separate "records" or "lines" within
	# a message component
	use constant message_record_separator => "\n";

	# Default field separator of date fields from input
	use constant date_field_separator => "/";

	# Default field separator of time fields from input
	use constant time_field_separator => ":";

	# Default character used to separate the start-date-time field
	# from the end-date-time field in a date-time range
	# specification
	use constant date_time_range_separator => ";";

	# Default character used to separate the date field from
	# the time field
	use constant date_time_separator => ",";

# Client request IDs

	# Request for a list of symbols for all available tradables
	use constant sym_list_req_id => '1';

	# Request for tradable data
	use constant data_req_id => '2';

	# Request whether daily data is available
	use constant daily_avail_req_id => '3';

	# Request whether intraday data is available
	use constant intra_avail_req_id => '4';

# Client request values

	use constant intraday_flag => 'i';

1;
