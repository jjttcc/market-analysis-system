indexing
	description: "Socket-based connections to an outside data supplier - %
		%Intended as a parent class to descendants implementing a protocol %
		%based on the data supplier they are associated with - i.e., using %
		%the strategy pattern"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined"

deferred class INPUT_DATA_CONNECTION inherit

	CLIENT_CONNECTION
		export
		redefine
			socket, server_type
		end

	DATA_SUPPLIER_COMMUNICATION_PROTOCOL
		export
			{NONE} all
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

	request_data_for (symbol: STRING) is
			-- Request data for `requester's current tradable identified
			-- by `symbol'.
		require
			connected: connected
			last_communication_succeeded: last_communication_succeeded
		do
			if last_communication_succeeded then
				send_request (tradable_data_request_msg (symbol), False)
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

feature {NONE} -- Hook routine implementations

	server_type: STRING is "data server "

	end_of_message (c: CHARACTER): BOOLEAN is
		do
			check
				not_used: False --!!!Verify not used.
			end
			Result := False -- Not used (I think!!!!)
		end

feature {NONE} -- Implementation

	tradable_data_request_msg (symbol: STRING): STRING is
		do
			Result := tradable_data_request.out + message_component_separator +
			date_time_range + message_component_separator + data_flags +
			message_component_separator + symbol + client_request_terminator
		end

	date_time_range: STRING is
			-- date/time range, for data request
		do
			Result := "" -- !!!Empty, for now
		end

	data_flags: STRING is
			-- intraday/non-intraday flag
		do
			Result := "" -- !!!Empty, for now
		end

feature {NONE} -- Implementation - Constants

	Timeout_seconds: INTEGER is
		once
			Result := 10
		end

invariant

end
