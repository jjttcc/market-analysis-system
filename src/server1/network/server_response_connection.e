indexing
	description: "Client socket connection for sending a response back to %
		%the process that started the MAS server"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%License to be determined"

class SERVER_RESPONSE_CONNECTION inherit

	CLIENT_CONNECTION
		export
			{NONE} connected
			{ANY} send_one_time_request
		end

creation

	make

feature -- Basic operations

feature {NONE} -- Implementation

feature {NONE} -- Implementation - constants

	Timeout_seconds: INTEGER is 10

	Message_date_field_separator: STRING is ""

	Message_time_field_separator: STRING is ""

invariant

end
