indexing
	description: "!!!!Fill in description!"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined"

class INPUT_SOCKET_CONNECTION inherit

	NETWORK_PROTOCOL
		export
			{NONE} all
		end

	CLIENT_CONNECTION
		export
			{ANY} close, send_request, make_connected_with_socket
		end

feature {NONE} -- Implementation - Constants

	Buffersize: INTEGER is 1

	Timeout_seconds: INTEGER is
		once
			Result := 10
		end

feature {NONE} -- Unused

	Message_date_field_separator: STRING is ""

	Message_time_field_separator: STRING is ""

invariant

end
