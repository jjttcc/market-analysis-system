indexing
	description: "Connections to an outside data supplier - Intended as %
		%a parent class for descendants implementing a protocol based on %
		%the data supplier they are associated with - i.e., the strategy %
		%pattern"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined"

deferred class INPUT_SOCKET_CONNECTION inherit

	CLIENT_CONNECTION
		export
			{ANY} close, send_request, make_connected_with_socket
		end

feature {NONE} -- Implementation - Constants

	Timeout_seconds: INTEGER is
		once
			Result := 10
		end

feature {NONE} -- Unused

	Message_date_field_separator: STRING is ""

	Message_time_field_separator: STRING is ""

invariant

end
