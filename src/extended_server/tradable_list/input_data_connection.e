indexing
	description: "Socket-based connections to an outside data supplier - %
		%Intended as a parent class INPUT_DATA_CONNECTION descendants %
		%implementing a protocol based on the data supplier they are %
		%associated with - i.e., the strategy pattern"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined"

deferred class INPUT_DATA_CONNECTION inherit

	CLIENT_CONNECTION
		export
			{ANY} close, send_request, make_connected_with_socket
		redefine
			socket, server_type
		end

feature -- Access

	socket: INPUT_SOCKET

	tradable_list: TRADABLE_LIST
			-- The tradable list associated with this connection

feature -- Element change

	set_tradable_list (arg: TRADABLE_LIST) is
			-- Set `tradable_list' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			tradable_list := arg
		ensure
			tradable_list_set: tradable_list = arg and tradable_list /= Void
		end

feature -- Basic operations

	initiate_connection is
			-- Initiate the connection to the data supplier.
		do
			connect_to_supplier
		ensure
			socket_exists_if_no_error:
				last_communication_succeeded implies socket /= Void
			socket_connected_iff_no_error:
				last_communication_succeeded = connected
		end

	request_data is
			-- Request data for `requester's current tradable.
		require
			connected: connected
			last_communication_succeeded: last_communication_succeeded
		do
			if last_communication_succeeded then
				send_request (data_request, False)
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

	data_request: STRING is
			-- Request string to send to data-supplier server for the
			-- data for `tradable_list's current tradable.
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
