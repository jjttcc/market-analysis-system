indexing
	description: "Socket-based connections to an outside data supplier - %
		%Intended as a parent class for descendants implementing a protocol %
		%based on the data supplier they are associated with - i.e., the %
		%strategy pattern"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined"

deferred class INPUT_DATA_CONNECTION inherit

	CLIENT_CONNECTION
--		export
--			{ANY} close, send_request, make_connected_with_socket
		redefine
			socket, server_type
		end

feature -- Access

	socket: INPUT_SOCKET

feature -- Basic operations

	request_data (requester: TRADABLE_LIST) is
			-- Request data for `requester's current tradable.
		do
			connect_to_supplier
			if last_communication_succeeded then
				send_request (data_request_for (requester), False)
			end
		ensure
			socket_exists_if_no_error:
				last_communication_succeeded implies socket /= Void
			socket_connected_iff_no_error:
				last_communication_succeeded = connected
		end

feature {NONE} -- Hook routines

	connect_to_supplier is
			-- Create `socket' and use it to connect to the data supplier
			-- as the first step in querying for new data.
		deferred
		end

	data_request_for (requester: TRADABLE_LIST): STRING is
			-- Request string to send to data-supplier server for the
			-- data for `requester's current tradable.
		deferred
		end

feature {NONE} -- Hook routine implementations

	server_type: STRING is "data server "

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
