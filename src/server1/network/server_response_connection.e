indexing
	description: "Client socket connection for sending a response back to %
		%the process that started the MAS server"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class SERVER_RESPONSE_CONNECTION inherit

	CLIENT_CONNECTION
		export
			{NONE} connected
			{ANY} send_one_time_request
		end

	MA_COMMUNICATION_PROTOCOL
		export
			{NONE} all
		end

creation

	make_tested

feature -- Basic operations

feature {NONE} -- Implementation

	end_of_message (c: CHARACTER): BOOLEAN is
			-- Does `c' indicate that the end of the data from the server
			-- has been reached?
		do
			Result := c = eom @ 1
		end

feature {NONE} -- Implementation - constants

	Timeout_seconds: INTEGER is 10

	Message_date_field_separator: STRING is ""

	Message_time_field_separator: STRING is ""

invariant

end
